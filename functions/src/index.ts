import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GameUtils} from "./game-utils";
import {GameLogic} from "./game-logic";
import {DocumentSnapshot, QueryDocumentSnapshot} from "firebase-functions/lib/providers/firestore";
import {Tile} from "./model/tile";

admin.initializeApp(functions.config().firebase);
export const firestore: FirebaseFirestore.Firestore = admin.firestore();

export const searchGame = functions.https.onCall((data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const playerName: string = context.auth?.token.name ?? null;
  const size: number = data.playersNumber;
  let gameId: string;
  let isGameFull: boolean;

  return firestore.runTransaction((transaction) => {
    return transaction.get(GameUtils.findGame(size))
        .then((gameResult) => {
          if (gameResult.size == 0) {
            gameId = GameUtils.createGame(transaction, playerId, playerName, size);
          } else {
            const result = GameUtils.addToGame(transaction, playerId, playerName, gameResult.docs[0]);
            gameId = result[0];
            isGameFull = result[1];
          }
        });
  }).then(() => {
    if (isGameFull) {
      GameUtils.startGame(gameId);
    }
    return {"gameId": gameId};
  });
});

export const putTiles = functions.https.onCall(async (data, context) => {
  const playerId: string = GameUtils.checkAuthentication(context.auth?.uid);
  const gameId: string = data.gameId;
  const tiles: Tile[][] = data.tiles;

  const playerQueue: FirebaseFirestore.QuerySnapshot =
      await firestore.collection("games/" + gameId + "/playersQueue").get();
  const result: [QueryDocumentSnapshot, QueryDocumentSnapshot] = GameLogic.checkTurn(playerQueue, playerId);

  const currentPlayer: DocumentSnapshot = result[0];
  const nextPlayer: DocumentSnapshot = result[1];

  GameLogic.validateTiles(gameId, currentPlayer, tiles);

  await currentPlayer.ref.update({currentTurn: false});
  await nextPlayer.ref.update({currentTurn: true});
});


