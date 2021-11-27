import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {DocumentSnapshot, QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
import {firestore} from "./index";
import {Tile} from "./model/tile";
import _ = require("lodash");

export class GameLogic {
  static async checkTurn(
      game: FirebaseFirestore.DocumentSnapshot,
      playersQueue: FirebaseFirestore.QuerySnapshot,
      playerId: string): Promise<[QueryDocumentSnapshot, QueryDocumentSnapshot]> {
    const playersNumber: number = playersQueue.size;
    for (let i = 0; i < playersNumber; i++) {
      const playerDoc: QueryDocumentSnapshot = playersQueue.docs[i];
      if (playerDoc.id === game.get("currentTurn")) {
        // const startedTime = game.updateTime?.toMillis() ?? 0;
        // if (Date.now() - startedTime < 62000) {
        if (playerDoc.id === playerId) {
          return [playerDoc, playersQueue.docs[(i + 1) % playersNumber]];
        }
        // }
      }
    }
    throw new functions.https.HttpsError("failed-precondition", "It's not your turn.");
  }

  static async addNewTiles(gameId: string, playerDoc: DocumentSnapshot,
      playerRack: FirebaseFirestore.QuerySnapshot, playerSets: Record<string, any>): Promise<string> {
    return await firestore.collection("games/" + gameId + "/state").doc("sets").get()
        .then((snapshot) => {
          const boardSets = snapshot.data();
          let boardTiles: Tile[] = [];
          let playerTiles: Tile[] = [];

          // jeśli gracz nie zmienia tablicy bierze kość z banku
          if (_.isEqual(boardSets, playerSets) || _.isEmpty(playerSets)) {
            return "empty";
          }

          // usuwamy niezmienione zbiory kości, różniące się zbiory rozdzielamy na tablicę kości
          for (const key in boardSets) {
            if (_.isEqual(boardSets[key], playerSets[key])) {
              delete boardSets[key];
              delete playerSets[key];
            } else {
              if (!playerSets[key]) {
                playerSets[key] = admin.firestore.FieldValue.delete();
              }
              boardTiles = boardTiles.concat(boardSets[key]);
            }
          }

          // pierwszy ruch gracza składa się tylko z własnych kostek i ich suma musi przekraczać 30
          // zbiory gracza, które się różniły również rozdzielamy na tablicę kości
          if (playerDoc.get("initialMeld") == false) {
            let total = 0;
            for (const key in playerSets) {
              this.validateSet(playerSets[key]);
              total += playerTiles.reduce(this.countTilesValue, 0);
              playerTiles = playerTiles.concat(playerSets[key]);
            }
            if (total < 30) {
              throw new functions.https.HttpsError("failed-precondition", "You are cheating!");
            }
          } else {
            for (const key in playerSets) {
              this.validateSet(playerSets[key]);
              playerTiles = playerTiles.concat(playerSets[key]);
            }
          }

          // usuwamy część wspólną zbiorów gracza i planszy
          const difference = playerTiles.filter((x) => !boardTiles.some((y, index) => {
            if (_.isEqual(x, y)) {
              delete boardTiles[index];
              return true;
            }
            return false;
          }));

          const playerTilesRack: FirebaseFirestore.DocumentReference[] = [];
          playerRack.docs.forEach((tile) => {
            const currentTile: Tile = <Tile>tile.data();
            difference.some((x, index) => {
              if (_.isEqual(x, currentTile)) {
                playerTilesRack.push(tile.ref);
                delete difference[index];
              }
            });
            if (difference.length === 0) {
              return;
            }
          });

          // warunek pierwszy - gracz nie posiadał takiej kości
          // warunek drugi - gracz nie przekazał wszystkich kości z planszy
          if (difference[0] !== undefined && boardTiles[0] !== undefined) {
            throw new functions.https.HttpsError("failed-precondition", "You are cheating!");
          } else {
            if (snapshot.data()) {
              firestore.collection("games/" + gameId + "/state").doc("sets").update(playerSets);
            } else {
              firestore.collection("games/" + gameId + "/state").doc("sets").set(playerSets);
            }
            playerTilesRack.forEach((docRef) => docRef.delete());
            if (playerDoc.get("initialMeld") == false) {
              playerDoc.ref.update({"initialMeld": true});
            }
            if (playerTilesRack.length === playerRack.docs.length) {
              return "winner";
            }
          }
          return "added";
        });
  }

  static async getTileFromPool(gameId: string, playerId: string): Promise<boolean> {
    return await firestore.collection("games/" + gameId + "/pool").limit(1).get()
        .then((snapshot) => {
          if (snapshot.docs[0]) {
            const tileDocument = snapshot.docs[0];
            firestore.collection("games/" + gameId + "/playersRacks/" + playerId + "/rack").doc()
                .set({color: tileDocument.data()["color"], number: tileDocument.data()["number"]});
            tileDocument.ref.delete();
            return true;
          } else {
            return false;
          }
        });
  }

  static async pointTheWinner(
      gameId: FirebaseFirestore.DocumentSnapshot,
      playersQueue: FirebaseFirestore.QuerySnapshot): Promise<void> {
    let winner: string[] = [];
    let number = 2548; // suma wszystkich kostek
    const playersNumber: number = playersQueue.size;
    for (let i = 0; i < playersNumber; i++) {
      const tiles = await playersQueue.docs[i].ref.collection("rack").get();
      const sum = tiles.docs.reduce((acc, x) => acc + x.get("number").number, 0);
      if (number > sum) {
        number = sum;
        winner = [playersQueue.docs[i].id];
      } else if (number === sum) {
        winner.push(playersQueue.docs[i].id);
      }
    }
  }

  private static countTilesValue(total: number, tile: Tile, index: number, tiles: Tile[]) {
    if (tile.number === 0) {
      let jokerNumber: number;
      if (this.isRun(tiles)) {
        jokerNumber = index > 0 ? tiles[index-1].number + 1 : tiles[index+1].number - 1;
      } else {
        jokerNumber = index > 0 ? tiles[index-1].number : tiles[index+1].number;
      }
      return total + jokerNumber;
    }
    return total + tile.number;
  }

  private static validateSet(set: Tile[]): void {
    if (set.length < 3 || (!this.isRun(set) && !this.isGroup(set))) {
      throw new functions.https.HttpsError("failed-precondition", "Board is not valid!");
    }
  }

  private static isRun(set: Tile[]): boolean {
    for (let i = 0; i < set.length - 1; i++) {
      if (set[i].number === 0 || set[i+1].number === 0) {
        continue;
      }
      if (set[i].number + 1 !== set[i+1].number || set[i].color !== set[i+1].color) {
        return false;
      }
    }
    return true;
  }

  private static isGroup(set: Tile[]): boolean {
    set.filter((e) => e.number != 0);
    const uniqueColors = new Set(set.map((tile) => tile.color));
    const uniqueNumbers = new Set(set.map((tile) => tile.number));
    return uniqueColors.size === set.length && uniqueNumbers.size === 1;
  }
}
