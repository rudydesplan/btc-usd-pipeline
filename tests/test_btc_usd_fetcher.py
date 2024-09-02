import os
import pytest
import json
import logging
import websocket
from unittest.mock import MagicMock, patch
from src.fetcher.btc_usd_fetcher import WebSocketKafkaConnector

@pytest.fixture
def mock_kafka(mocker):
    mock_producer = MagicMock()
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer', return_value=mock_producer)
    return mock_producer

@pytest.fixture
def connector(mock_kafka):
    with patch('src.fetcher.btc_usd_fetcher.WebSocketKafkaConnector.connect_to_kafka'):
        return WebSocketKafkaConnector()

def test_connect_to_kafka_success(mocker, mock_kafka):
    with patch('src.fetcher.btc_usd_fetcher.WebSocketKafkaConnector.connect_to_kafka'):
        connector = WebSocketKafkaConnector()
        assert connector.producer is not None

def test_connect_to_kafka_failure(mocker):
    mocker.patch('src.fetcher.btc_usd_fetcher.KafkaProducer', side_effect=Exception('Kafka error'))
    with pytest.raises(ConnectionError):
        WebSocketKafkaConnector()

def test_on_message_with_valid_data(connector):
    valid_message = json.dumps({
        "data": [
            {
                "p": 7296.89,
                "s": "BINANCE:BTCUSD",
                "t": 1575526691134,
                "v": 0.011467
            }
        ],
        "type": "trade"
    })
    
    connector.on_message(None, valid_message)
    
    connector.producer.send.assert_called_once_with(
        os.environ.get('KAFKA_TOPIC', 'default_topic'),
        valid_message.encode('utf-8')
    )

def test_on_message_with_empty_data(connector):
    empty_message = json.dumps({
        "data": [],
        "type": "trade"
    })
    
    connector.on_message(None, empty_message)
    
    connector.producer.send.assert_called_once_with(
        os.environ.get('KAFKA_TOPIC', 'default_topic'),
        empty_message.encode('utf-8')
    )

def test_on_message_with_invalid_json(connector):
    invalid_message = "This is not a JSON message"
    
    with pytest.raises(json.JSONDecodeError):
        connector.on_message(None, invalid_message)

def test_on_open(connector):
    mock_ws = MagicMock()
    connector.on_open(mock_ws)
    
    expected_message = json.dumps({
        'type': 'subscribe',
        'symbol': 'BINANCE:BTCUSD'
    })
    mock_ws.send.assert_called_once_with(expected_message)

def test_graceful_shutdown(connector):
    connector.ws = MagicMock()
    connector.producer = MagicMock()
    
    connector.graceful_shutdown(None, None)
    
    connector.ws.close.assert_called_once()
    connector.producer.close.assert_called_once()

def test_on_error_reconnect(connector):
    connector.connect_to_websocket = MagicMock()
    error = websocket.WebSocketConnectionClosedException()
    
    connector.on_error(None, error)
    
    connector.connect_to_websocket.assert_called_once()