using Mechanics;
using Main;
using Network;
using TMPro;
using UI;
using UnityEngine;
using UnityEngine.Networking;

namespace Characters
{
    public class ShipController : NetworkMovableObject
    {
        public string PlayerName
        {
            get => _playerName;
            set => _playerName = value;
        }
        
        public Canvas NameCanvas
        {
            get => _nameCanvas;
            set => _nameCanvas = value;
        }
        
        public Color PlayerColor
        {
            get => _playerColor;
            set => _playerColor = value;
        }

        protected override float _speed => _shipSpeed;

        [SerializeField] private Transform _cameraAttach;
        private CameraOrbit _cameraOrbit;
        private PlayerLabel _playerLabel;
        private float _shipSpeed;
        private Rigidbody _rb;
        private string _color;
        
#pragma warning disable 618
        [SyncVar] private string _playerName;
        
        [SyncVar] private Canvas _nameCanvas;

        [SyncVar] private Color _playerColor; 
#pragma warning disable 618
        
        private void OnGUI()
        {
            if (_cameraOrbit == null)
            {
                return;
            }
            
            _cameraOrbit.ShowPlayerLabels(_playerLabel);
        }
        
        public override void OnStartClient()
        {
            GetComponent<Renderer>().material.color = _playerColor;
            gameObject.name = _playerName;
        }
        
        public override void OnStartAuthority()
        {
            _rb = GetComponent<Rigidbody>();
            
            if (_rb == null)
            {
                return;
            }
            
            //gameObject.name = _playerName;
            _cameraOrbit = FindObjectOfType<CameraOrbit>();
            _cameraOrbit.Initiate(_cameraAttach == null ? transform :
                _cameraAttach);
            _playerLabel = GetComponentInChildren<PlayerLabel>();
            _nameCanvas.gameObject.SetActive(false);
            base.OnStartAuthority();
        }
        
        protected override void HasAuthorityMovement()
        {
            var spaceShipSettings = SettingsContainer.Instance?.SpaceShipSettings;
            
            if (spaceShipSettings == null)
            {
                return;
            }
            
            var isFaster = Input.GetKey(KeyCode.LeftShift);
            
            var speed = spaceShipSettings.ShipSpeed;
            
            var faster = isFaster ? spaceShipSettings.Faster : 1.0f;
            _shipSpeed = Mathf.Lerp(_shipSpeed, speed * faster,
                SettingsContainer.Instance.SpaceShipSettings.Acceleration);
            
            var currentFov = isFaster ? SettingsContainer.Instance.SpaceShipSettings.FasterFov :
                SettingsContainer.Instance.SpaceShipSettings.NormalFov;
            _cameraOrbit.SetFov(currentFov, SettingsContainer.Instance.SpaceShipSettings.ChangeFovSpeed);
            
            var velocity =
                _cameraOrbit.transform.TransformDirection(Vector3.forward) * _shipSpeed;
            _rb.velocity = velocity * Time.deltaTime;
            
            if (!Input.GetKey(KeyCode.C))
            {
                var targetRotation = Quaternion.LookRotation(
                    Quaternion.AngleAxis(_cameraOrbit.LookAngle,
                        -transform.right) *
                    velocity);
                transform.rotation = Quaternion.Slerp(transform.rotation,
                    targetRotation, Time.deltaTime * speed);
            }
        }
        
        protected override void FromServerUpdate() { }
        
        protected override void SendToServer() { }

        [ClientCallback]
        private void LateUpdate()
        {
            //gameObject.name = _playerName;
            _cameraOrbit?.CameraMovement();
        }

        [ServerCallback]
        private void OnTriggerEnter(Collider other)
        {
            /*ShipDisable();
            transform.position = new Vector3(50,50,50);
            ShipEnable();*/
            RpcChangePosition(new Vector3(50, 50, 50));
        }

        [ClientRpc]
        public void RpcChangePosition(Vector3 position)
        {
            ShipDisable();
            transform.position = position;
            ShipEnable();
        }
        
        private void ShipEnable()
        {
            gameObject.SetActive(true);
        }
        
        private void ShipDisable()
        {
            gameObject.SetActive(false);
        }
    }
}