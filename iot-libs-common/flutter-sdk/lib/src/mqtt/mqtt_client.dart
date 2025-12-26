/// MQTT 客户端封装
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';

import '../models/device.dart';
import '../utils/config.dart';
import '../utils/logger.dart';
import 'mqtt_message.dart';

/// MQTT 连接状态
enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

/// MQTT 客户端
class IoTMqttClient {
  final IoTConfig config;
  final Device device;

  MqttServerClient? _client;
  MqttConnectionState _connectionState = MqttConnectionState.disconnected;

  // 消息流
  final _messageController = BehaviorSubject<IoTMessage>();
  final _connectionStateController = BehaviorSubject<MqttConnectionState>.seeded(
    MqttConnectionState.disconnected,
  );

  // 订阅的 topic 列表
  final Set<String> _subscribedTopics = {};

  // 服务调用响应等待
  final Map<String, Completer<ServiceReplyMessage>> _pendingCalls = {};

  IoTMqttClient({
    required this.config,
    required this.device,
  });

  /// 连接状态流
  Stream<MqttConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// 消息流
  Stream<IoTMessage> get messageStream => _messageController.stream;

  /// 当前连接状态
  MqttConnectionState get connectionState => _connectionState;

  /// 是否已连接
  bool get isConnected => _connectionState == MqttConnectionState.connected;

  /// 连接 MQTT 服务器
  Future<bool> connect() async {
    if (_connectionState == MqttConnectionState.connected ||
        _connectionState == MqttConnectionState.connecting) {
      return _connectionState == MqttConnectionState.connected;
    }

    _setConnectionState(MqttConnectionState.connecting);

    try {
      final clientId = '${device.productKey}_${device.deviceId}_app';

      _client = MqttServerClient(config.mqttHost, clientId);
      _client!.port = config.mqttPort;
      _client!.keepAlivePeriod = 60;
      _client!.autoReconnect = true;
      _client!.resubscribeOnAutoReconnect = true;
      _client!.logging(on: config.enableLogging);

      // 设置回调
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onAutoReconnect = _onAutoReconnect;
      _client!.onAutoReconnected = _onAutoReconnected;
      _client!.onSubscribed = _onSubscribed;

      // SSL 配置
      if (config.useSSL) {
        _client!.secure = true;
        _client!.securityContext = SecurityContext.defaultContext;
      }

      // 连接消息
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(
            device.mqttUsername ?? '${device.productKey}&${device.deviceId}',
            device.mqttPassword ?? '',
          )
          .withWillTopic('${device.topicPrefix}/thing/status')
          .withWillMessage(json.encode({'status': 'offline'}))
          .withWillQos(MqttQos.atLeastOnce)
          .startClean();

      _client!.connectionMessage = connMessage;

      IoTLogger.info('正在连接 MQTT: ${config.mqttHost}:${config.mqttPort}', 'MQTT');

      final result = await _client!.connect();

      if (result?.state == MqttConnectionState.connected) {
        _setupMessageListener();
        _subscribeDefaultTopics();
        return true;
      }

      _setConnectionState(MqttConnectionState.disconnected);
      return false;
    } catch (e, stack) {
      IoTLogger.error('MQTT 连接失败: $e', 'MQTT', e, stack);
      _setConnectionState(MqttConnectionState.disconnected);
      return false;
    }
  }

  /// 断开连接
  void disconnect() {
    if (_client != null) {
      _setConnectionState(MqttConnectionState.disconnecting);
      _client!.disconnect();
      _client = null;
    }
    _setConnectionState(MqttConnectionState.disconnected);
  }

  /// 订阅 topic
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    if (!isConnected || _subscribedTopics.contains(topic)) return;

    _client?.subscribe(topic, qos);
    _subscribedTopics.add(topic);
    IoTLogger.debug('订阅 topic: $topic', 'MQTT');
  }

  /// 取消订阅
  void unsubscribe(String topic) {
    if (!isConnected || !_subscribedTopics.contains(topic)) return;

    _client?.unsubscribe(topic);
    _subscribedTopics.remove(topic);
    IoTLogger.debug('取消订阅: $topic', 'MQTT');
  }

  /// 发布消息
  void publish(String topic, String payload, {MqttQos qos = MqttQos.atLeastOnce}) {
    if (!isConnected) {
      IoTLogger.warning('MQTT 未连接，无法发布消息', 'MQTT');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    _client?.publishMessage(topic, qos, builder.payload!);
    IoTLogger.debug('发布消息: $topic', 'MQTT');
  }

  /// 上报属性
  void reportProperty(Map<String, dynamic> properties) {
    final message = PropertyReportMessage.create(properties);
    publish(
      device.propertyPostTopic,
      json.encode(message.toJson()),
    );
  }

  /// 调用设备服务 (等待响应)
  Future<ServiceReplyMessage> callService(
    String serviceId,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final topic = '${device.topicPrefix}/thing/service/$serviceId';
    final replyTopic = '$topic\_reply';

    // 确保订阅响应 topic
    subscribe(replyTopic);

    // 创建等待响应的 Completer
    final completer = Completer<ServiceReplyMessage>();
    _pendingCalls[messageId] = completer;

    // 发送服务调用
    final message = ServiceCallMessage(
      id: messageId,
      method: serviceId,
      params: params,
    );
    publish(topic, json.encode(message.toJson()));

    // 等待响应或超时
    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      _pendingCalls.remove(messageId);
      throw Exception('服务调用超时: $serviceId');
    }
  }

  /// 设置消息监听
  void _setupMessageListener() {
    _client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? messages) {
      if (messages == null) return;

      for (final msg in messages) {
        final payload = msg.payload as MqttPublishMessage;
        final payloadStr = MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );

        final iotMessage = IoTMessage(
          topic: msg.topic,
          payload: payloadStr,
          qos: payload.header?.qos?.index ?? 0,
          timestamp: DateTime.now(),
        );

        _messageController.add(iotMessage);
        _handleMessage(iotMessage);
      }
    });
  }

  /// 处理接收到的消息
  void _handleMessage(IoTMessage message) {
    // 处理服务响应
    if (message.messageType == IoTMessageType.serviceReply) {
      final json = message.jsonPayload;
      if (json != null) {
        final reply = ServiceReplyMessage.fromJson(json);
        final completer = _pendingCalls.remove(reply.id);
        completer?.complete(reply);
      }
    }
  }

  /// 订阅默认 topic
  void _subscribeDefaultTopics() {
    // 属性设置
    subscribe(device.propertySetTopic);
    // 服务调用
    subscribe('${device.topicPrefix}/thing/service/+');
    // 服务响应
    subscribe('${device.topicPrefix}/thing/service/+_reply');
  }

  void _setConnectionState(MqttConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _onConnected() {
    IoTLogger.info('MQTT 已连接', 'MQTT');
    _setConnectionState(MqttConnectionState.connected);
  }

  void _onDisconnected() {
    IoTLogger.info('MQTT 已断开', 'MQTT');
    _setConnectionState(MqttConnectionState.disconnected);
  }

  void _onAutoReconnect() {
    IoTLogger.info('MQTT 正在重连...', 'MQTT');
    _setConnectionState(MqttConnectionState.connecting);
  }

  void _onAutoReconnected() {
    IoTLogger.info('MQTT 重连成功', 'MQTT');
    _setConnectionState(MqttConnectionState.connected);
  }

  void _onSubscribed(String topic) {
    IoTLogger.debug('订阅成功: $topic', 'MQTT');
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionStateController.close();
  }
}
