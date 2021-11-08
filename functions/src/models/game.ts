export interface Game {
    isFull: boolean;
    size: number;
    players: {[p: string]: boolean};
}
