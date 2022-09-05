using System.Collections.Generic;
using Characters;
using TMPro;
using UnityEngine;
using UnityEngine.Networking;

namespace Main
{
    public class SolarSystemNetworkManager : NetworkManager
    {
        //[SerializeField] private string _playerName;
        [SerializeField] private Canvas _nameCanvas;
        [SerializeField] private TMP_InputField _nameText;
        [SerializeField] private Color _playerColor;

        private Dictionary<int, ShipController> _players = new Dictionary<int, ShipController>();

        public override void OnStartServer()
        {
            NetworkServer.RegisterHandler(200, GetName);
            base.OnStartServer();
        }

        public override void OnServerAddPlayer(NetworkConnection conn, short
            playerControllerId)
        {
            var spawnTransform = GetStartPosition();
            
            var player = Instantiate(playerPrefab, spawnTransform.position,
                spawnTransform.rotation);
            
            player.GetComponent<ShipController>().PlayerName = _nameText.text;
            player.GetComponent<ShipController>().NameCanvas= _nameCanvas;
            player.GetComponent<ShipController>().PlayerColor = _playerColor;
            
            _players.Add(conn.connectionId, player.GetComponent<ShipController>());
            
            NetworkServer.AddPlayerForConnection(conn, player, playerControllerId);
        }

        public override void OnClientConnect(NetworkConnection conn)
        {
            MessageLogin _messageLogin = new MessageLogin();
            _messageLogin.Name = _nameText.text;
            conn.Send(200, _messageLogin);
            base.OnClientConnect(conn);
            _nameCanvas.gameObject.SetActive(false);
        }
        
        public class MessageLogin : MessageBase
        {
            public string Name;
            
            public virtual void Deserialize(NetworkReader reader)
            {
                Name = reader.ReadString();
            }

            public virtual void Serialize(NetworkWriter writer)
            {
                writer.Write(Name);
            }
        }

        private void GetName(NetworkMessage networkMessage)
        {
            _players[networkMessage.conn.connectionId].PlayerName = networkMessage.reader.ReadString();
        }
    }
}