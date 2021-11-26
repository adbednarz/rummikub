import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {DocumentSnapshot, QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
import {firestore} from "./index";
import {Tile} from "./model/tile";
import _ = require("lodash");

export class GameLogic {
  static async checkTurn(gameId: string, playerId: string): Promise<[QueryDocumentSnapshot, QueryDocumentSnapshot]> {
    const game: FirebaseFirestore.DocumentSnapshot = await firestore.collection("games/").doc(gameId).get();
    const playersQueue: FirebaseFirestore.QuerySnapshot =
        await firestore.collection("games/" + gameId + "/playersQueue").get();
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

  static addNewTiles(gameId: string, playerDoc: DocumentSnapshot,
      playerRack: FirebaseFirestore.QuerySnapshot, playerSets: Record<string, any>): void {
    firestore.collection("games/" + gameId + "/state").doc("sets").get()
        .then((snapshot) => {
          const boardSets = snapshot.data();
          let boardTiles: Tile[] = [];
          let playerTiles: Tile[] = [];

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

          // zbiory gracza, które się różniły również rozdzielamy na tablicę kości
          for (const key in playerSets) {
            this.validateSet(playerSets[key]);
            playerTiles = playerTiles.concat(playerSets[key]);
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
          playerRack.forEach((tile) => {
            const currentTile: Tile = <Tile> tile.data();
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
          }
        });
  }

  static validateSet(set: Tile[]): void {
    functions.logger.log(set);
    if (set.length < 3 && !this.isRun(set) && !this.isGroup(set)) {
      throw new functions.https.HttpsError("failed-precondition", "Board is not valid!");
    }
  }

  static isRun(set: Tile[]): boolean {
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

  static isGroup(set: Tile[]): boolean {
    set.filter((e) => e.number != 0);
    const uniqueColors = new Set(set.map((tile) => tile.color));
    const uniqueNumbers = new Set(set.map((tile) => tile.number));
    return uniqueColors.size === set.length && uniqueNumbers.size === 1;
  }
}
