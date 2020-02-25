using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

/// <summary>
/// Listens for touch events and performs an AR raycast from the screen touch point.
/// AR raycasts will only hit detected trackables like feature points and planes.
///
/// If a raycast hits a trackable, the <see cref="placedPrefab"/> is instantiated
/// and moved to the hit position.
/// </summary>
[RequireComponent(typeof(ARRaycastManager))]
public class HandleInput : MonoBehaviour
{
    const int backgroundLayer = 10;
    const int characterLayer = 11;

    [SerializeField]
    [Tooltip("Instantiates this background on a plane at the touch location, and the characterPrefab to follow")]
    GameObject backgroundPrefab;
    [SerializeField]
    GameObject characterPrefab;
    [SerializeField]
    Camera mainCamera;
    [SerializeField]
    ARSessionOrigin sessionOrigin;
    public SpawnItemsToBeFound spawner;

    GameObject _instantiatedCharacter;
    NavMeshAgent _characterNavAgent;

    int physicalLayerMask = (1 << backgroundLayer) | (1 << characterLayer);
    /// <summary>
    /// The prefab to instantiate on touch.
    /// </summary>
    public GameObject placedPrefab
    {
        get { return backgroundPrefab; }
        set { backgroundPrefab = value; }
    }

    /// <summary>
    /// The object instantiated as a result of a successful raycast intersection with a plane.
    /// </summary>
    public GameObject spawnedBackground { get; private set; }

    void Awake()
    {
        m_RaycastManager = GetComponent<ARRaycastManager>();
    }

    bool TryGetTouchPosition(out Vector2 touchPosition)
    {
#if UNITY_EDITOR
        if (Input.GetMouseButton(0))
        {
            var mousePosition = Input.mousePosition;
            touchPosition = new Vector2(mousePosition.x, mousePosition.y);
            return true;
        }
#else
        if (Input.touchCount > 0)
        {
            touchPosition = Input.GetTouch(0).position;
            return true;
        }
#endif

        touchPosition = default;
        return false;
    }

    public void OnValueChanged(float sliderScale)
    {
        sessionOrigin.transform.localScale = new Vector3(sliderScale, sliderScale, sliderScale);
    }

    void Update()
    {
        if (!TryGetTouchPosition(out Vector2 touchPosition))
            return;

        var ray = mainCamera.ScreenPointToRay(touchPosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, 500, physicalLayerMask))
        {
            if(hit.transform.gameObject.layer == backgroundLayer)
            {
                Debug.Log("Moving Instiated Character to " + hit.point);
                _characterNavAgent.destination = hit.point;
            }
        }
        else if (m_RaycastManager.Raycast(touchPosition, s_Hits, TrackableType.PlaneWithinPolygon))
        {
            // Raycast hits are sorted by distance, so the first one
            // will be the closest hit.
            var hitPose = s_Hits[0].pose;

            if (spawnedBackground == null)
            {
                spawnedBackground = Instantiate(backgroundPrefab, hitPose.position, hitPose.rotation);
                spawner.SetBackgroundToSpawnOn(spawnedBackground.transform);
                
                sessionOrigin.MakeContentAppearAt(spawnedBackground.transform, hitPose.position, hitPose.rotation);
                _instantiatedCharacter = Instantiate(characterPrefab, hitPose.position, hitPose.rotation);
                _characterNavAgent = _instantiatedCharacter.GetComponentInChildren<NavMeshAgent>();
                spawner.SetCharacter(_instantiatedCharacter.GetComponent<CharacterController>());
                DisablePlanes();
            }
            else
            {
                spawnedBackground.transform.position = hitPose.position;
                _instantiatedCharacter.transform.position = hitPose.position;
            }
        }
    }

    void DisablePlanes()
    {
        var planeManager = GetComponent<ARPlaneManager>();
        planeManager.enabled = false;

        foreach (ARPlane plane in planeManager.trackables)
        {
            plane.gameObject.SetActive(false);
        }
    }

    static List<ARRaycastHit> s_Hits = new List<ARRaycastHit>();

    ARRaycastManager m_RaycastManager;
}
