using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Tech.General;
using UnityEngine;
using UnityEngine.UI;

public class SpawnItemsToBeFound : MonoBehaviour
{
    public Transform MainBackgroundPrefab;
    public GameObject[] PossibleGameObjects;
    public CharacterController characterController;
    public Text _textDisplay;
    public int totalItemsToSpawn = 3;

    public void SetBackgroundToSpawnOn(Transform mainBackgroundPrefab)
    {
        MainBackgroundPrefab = mainBackgroundPrefab;
        var SpawnPoints = GameObject.FindGameObjectsWithTag("Spawner");
        Debug.Log("Spawn Point Count:" + SpawnPoints.Length);
        var possibleGameObjectsList = PossibleGameObjects.ToList();
        possibleGameObjectsList.RandomizeOrder();
        var SpawnPointsList = SpawnPoints.ToList();
        SpawnPointsList.RandomizeOrder();

        for (var i = 0; i < 3; i++)
        {
            var spawnPoint = SpawnPointsList[i];

            var instantiatedGameObject = Instantiate(possibleGameObjectsList[i], spawnPoint.transform.position, spawnPoint.transform.rotation);
            Debug.Log("Spawning Game Object" + instantiatedGameObject.name + " at " + spawnPoint.transform.position);

            var spawnedObject = spawnPoint.GetComponent<SpawnedObject>();
            spawnedObject.CollidedWithSomething += CharacterFoundItem;

            instantiatedGameObject.transform.parent = spawnPoint.transform;
            instantiatedGameObject.transform.localPosition = Vector3.zero;
        }

    }

    internal void SetCharacter(CharacterController characterController)
    {
        characterController.ItemFoundEvent -= CharacterFoundItem;
        characterController.ItemFoundEvent += CharacterFoundItem;
    }

    void CharacterFoundItem(Transform obj)
    {
        Destroy(obj.gameObject);

        if(--totalItemsToSpawn <= 0)
        {
            _textDisplay.text = "Yay you found all the items!";
        }
        else
        {
            _textDisplay.text = totalItemsToSpawn + " item" + ((totalItemsToSpawn > 1) ? "s" : "") + " left to be found!";
        }
    }
}
