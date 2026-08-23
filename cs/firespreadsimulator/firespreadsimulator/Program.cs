string fileName = "forest_grid_1.txt";
char[,] fireSpreadGrid = new char[4, 4];
List<Vector2i> firePositions = new();
Vector2i? lastFireSpreadTile = null;
int step = 0;
int treeCount = 0;
Vector2i windDirection;

//enterPath();

Dictionary<Vector2i, char> CardinalDirections = new() {
    { new Vector2i(-1,  0), 'W' },
    { new Vector2i( 1,  0), 'E' },
    { new Vector2i( 0,  1), 'S' },
    { new Vector2i( 0, -1), 'N' }
};

try {
    using StreamReader sr = new(fileName);
    string line;
    int yPos = 0;
    bool firstLineDrawn = false;

    while ((line = sr.ReadLine()) != null) {
        // check if area is defined
        if (!firstLineDrawn) {
            firstLineDrawn = true;
            string[] possibleAreaDefinition = line.Split(' ');
            if (possibleAreaDefinition.Length == 2 && int.TryParse(possibleAreaDefinition[0], out int height) && int.TryParse(possibleAreaDefinition[1], out int width)) {
                fireSpreadGrid = new char[width, height];
            }
            printBar(fireSpreadGrid.GetLength(0));
            continue;
        }
        Console.Write("|");
        for (int i = 0; i < fireSpreadGrid.GetLength(0) + (fireSpreadGrid.GetLength(0) - 1); i++) {
            char currentPosValue = line[i];
            if (currentPosValue != ' ') {
                if (currentPosValue == 'F') {
                    firePositions.Add(new Vector2i(i / 2, yPos));
                } else if (currentPosValue == 'T') {
                    treeCount++;
                }
                fireSpreadGrid[i / 2, yPos] = currentPosValue;
            }
            Console.Write(currentPosValue);
        }
        Console.Write("|");
        yPos++;
        Console.WriteLine();
    }
    printBar(fireSpreadGrid.GetLength(0));
} catch (Exception e) {
    Console.WriteLine("The file could not be read:");
    Console.WriteLine(e.Message);
    Console.WriteLine("Press any key to enter a valid txt.");
    Console.ReadKey();
    enterPath();
}

while (true) {
    Console.WriteLine("Please enter a square to set on fire! Eg: X,Y");
    string[] initialFireSquareInputSplit = Console.ReadLine().Split(',');

    if (!int.TryParse(initialFireSquareInputSplit[0], out int x) || x >= fireSpreadGrid.GetLength(0) || x < 0) {
        Console.WriteLine("Your X value was invalid!");
        continue;
    }

    if (!int.TryParse(initialFireSquareInputSplit[1], out int y) || y >= fireSpreadGrid.GetLength(0) || y < 0) {
        Console.WriteLine("Your Y value is invalid!");
        continue;
    }

    if (fireSpreadGrid[x, y] == 'T') {
        treeCount--;
    }
    
    addFirePosition(new Vector2i(x, y));
    break;
}

while (true) {
    Console.WriteLine("Enter a direction that the wind blows (N, E, S, W)");
    char inputDirection = char.ToUpper(Console.ReadKey().KeyChar);
    Console.WriteLine();

    if (CardinalDirections.ContainsValue(inputDirection)) {
        windDirection = CardinalDirections.FirstOrDefault(direction => direction.Value == inputDirection).Key;
        break;
    } else {
        Console.WriteLine("Invalid direction!");
    }
}

List<Vector2i> frontier = [.. firePositions];
regenerateFireSpreadGrid();


void enterPath() {
    while (!File.Exists(fileName)) {
        Console.Clear();
        Console.WriteLine("Please enter the name of a valid file to read!");
        fileName = Console.ReadLine();
    }
}

void printBar(int gridSizeX) {
    Console.WriteLine("+" + new string('-', gridSizeX + (gridSizeX - 1)) + "+");
}

void regenerateFireSpreadGrid() {
    printBar(fireSpreadGrid.GetLength(0));
    for (int y = 0; y < fireSpreadGrid.GetLength(1); y++) {
        Console.Write("|");
        for (int x = 0; x < fireSpreadGrid.GetLength(0); x++) {
            Console.Write(fireSpreadGrid[x, y]);
            if (x < fireSpreadGrid.GetLength(0) - 1) {
                Console.Write(" ");
            }
        }
        Console.Write("|");
        Console.WriteLine();
    }
    printBar(fireSpreadGrid.GetLength(1));
    step++;

    if (updateFire()) {
        Console.WriteLine("Press any key to continue spread.");
        Console.ReadKey();
        regenerateFireSpreadGrid();
    } else {
        Console.WriteLine("Spread simulation has completed (the fire can't spread any further)");
        Console.WriteLine(treeCount + " trees remain with " + (firePositions.Count - 1) + " having been burned since the initial grid was built.");
        Console.WriteLine("It took " + step + " steps to complete.");
    }

}

bool updateFire() {
    List<Vector2i> newFrontier = [];

    foreach (Vector2i firePos in frontier) {
        foreach (Vector2i direction in CardinalDirections.Keys) {
            Vector2i next = firePos + direction;
            if (attemptFireSpreadToTile(next)) {
                newFrontier.Add(next);
                if (direction == windDirection) {
                    Vector2i windNext = next + direction;
                    if (attemptFireSpreadToTile(windNext)) {
                        newFrontier.Add(windNext);
                    }
                }
            }
        }
    }

    // two fires can have the same neighbouring tree
    List<Vector2i> distinct = [.. newFrontier.Distinct()];
    foreach (Vector2i pos in distinct) {
        addFirePosition(pos);
    }

    frontier = distinct;
    return distinct.Count > 0;
}

bool attemptFireSpreadToTile(Vector2i pos) {
    return isPositionValid(pos) && fireSpreadGrid[pos.X, pos.Y] == 'T';
}

void addFirePosition(Vector2i position) {
    if (isPositionValid(position)) {
        fireSpreadGrid[position.X, position.Y] = 'F';
        firePositions.Add(position);
    } else {
        Console.WriteLine("New fire position was invalid! Not added to grid!");
    }
}

bool isPositionValid(Vector2i pos) {
    return pos.X < fireSpreadGrid.GetLength(0)
                && pos.X >= 0
                && pos.Y < fireSpreadGrid.GetLength(1)
                && pos.Y >= 0;
}

struct Vector2i(int x, int y) {
    public int X { get; set; } = x;
    public int Y { get; set; } = y;

    public static Vector2i operator +(Vector2i vector1, Vector2i vector2) {
        return new Vector2i(vector1.X + vector2.X, vector1.Y + vector2.Y);
    }

    public static bool operator ==(Vector2i vector1, Vector2i vector2) {
        return (vector1.X == vector2.X && vector1.Y == vector2.Y);
    }

    public static bool operator !=(Vector2i vector1, Vector2i vector2) {
        return !(vector1.X == vector2.X && vector1.Y == vector2.Y);
    }
    public override readonly string ToString() => $"({X}, {Y})";
}

struct GridPosition(Vector2i pos, char type) {
    public Vector2i POS { get; set; } = pos;
    public char TYPE { get; set; } = type;
}