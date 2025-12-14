<?php
header("Content-Type: application/json");
error_reporting(E_ALL);
ini_set('display_errors', 0);

include 'db_connect.php';

$action = $_GET['action'] ?? '';

switch ($action) {
    case 'read_all':
        read_all($conn);
        break;
    case 'create':
        create_book($conn);
        break;
    case 'read_detail':
        read_detail($conn);
        break;
    default:
        echo json_encode(["success" => false, "message" => "Invalid action."]);
        break;
}

// ---------- CREATE ----------
function create_book($conn) {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(["success" => false, "message" => "Use POST method"]);
        return;
    }

    $data = json_decode(file_get_contents("php://input"), true);

    if ($data === null) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Invalid JSON"]);
        return;
    }

    $title = $data['title'] ?? '';
    $summary = $data['summary'] ?? '';
    $author = $data['author'] ?? '';

    if (empty($title) || empty($author)) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Title and author required"]);
        return;
    }

    $stmt = $conn->prepare("INSERT INTO books (title, summary, author) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $title, $summary, $author);

    if ($stmt->execute()) {
        echo json_encode([
            "success" => true,
            "book_id" => $conn->insert_id
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => $stmt->error]);
    }

    $stmt->close();
}

// ---------- READ ALL ----------
function read_all($conn) {
    $result = $conn->query("SELECT id, title, summary, author, created_at FROM books ORDER BY created_at DESC");
    $books = [];

    while ($row = $result->fetch_assoc()) {
        $books[] = $row;
    }

    echo json_encode(["success" => true, "data" => $books]);
}

// ---------- READ DETAIL ----------
function read_detail($conn) {
    $book_id = $_GET['book_id'] ?? 0;

    if ($book_id == 0) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Book ID required"]);
        return;
    }

    $stmt = $conn->prepare("SELECT id, title, summary, author, created_at FROM books WHERE id = ?");
    $stmt->bind_param("i", $book_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        http_response_code(404);
        echo json_encode(["success" => false, "message" => "Book not found"]);
        return;
    }

    $book = $result->fetch_assoc();

    $stmt_ch = $conn->prepare(
        "SELECT id, book_id, chapter_number, content 
         FROM chapters WHERE book_id = ? ORDER BY chapter_number ASC"
    );
    $stmt_ch->bind_param("i", $book_id);
    $stmt_ch->execute();
    $res_ch = $stmt_ch->get_result();

    $chapters = [];
    while ($row = $res_ch->fetch_assoc()) {
        $chapters[] = $row;
    }

    $book['chapters'] = $chapters;

    echo json_encode([
        "success" => true,
        "data" => $book
    ]);

    $stmt->close();
    $stmt_ch->close();
}

$conn->close();
