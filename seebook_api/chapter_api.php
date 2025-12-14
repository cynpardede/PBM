<?php
// Sertakan file koneksi database
include 'db_connect.php';

// Ambil aksi yang diminta dari parameter GET
$action = $_GET['action'] ?? '';

switch ($action) {
    case 'create':
        create_chapter($conn);
        break;
    // Tambahkan case 'read_by_book_id', 'update', dan 'delete' nanti
    default:
        echo json_encode(array("success" => false, "message" => "Invalid action."));
        break;
}

// --- FUNGSI CREATE (POST) ---
function create_chapter($conn) {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(array("success" => false, "message" => "Method not allowed. Use POST."));
        return;
    }

    $data = json_decode(file_get_contents("php://input"), true);
    
    $book_id = $data['book_id'] ?? 0;
    $content = $data['content'] ?? '';

    // Validasi input
    if ($book_id == 0 || empty($content)) {
        http_response_code(400);
        echo json_encode(array("success" => false, "message" => "Book ID and Content are required."));
        return;
    }

    // 1. Dapatkan nomor bab berikutnya untuk buku ini
    $stmt_max = $conn->prepare("SELECT MAX(chapter_number) AS max_chapter FROM chapters WHERE book_id = ?");
    $stmt_max->bind_param("i", $book_id);
    $stmt_max->execute();
    $result_max = $stmt_max->get_result();
    $row_max = $result_max->fetch_assoc();
    $next_chapter_number = ($row_max['max_chapter'] ?? 0) + 1;
    $stmt_max->close();

    // 2. Insert bab baru
    $stmt_insert = $conn->prepare("INSERT INTO chapters (book_id, chapter_number, content) VALUES (?, ?, ?)");
    $stmt_insert->bind_param("iis", $book_id, $next_chapter_number, $content);

    if ($stmt_insert->execute()) {
        echo json_encode(array("success" => true, "message" => "Chapter created successfully.", "chapter_number" => $next_chapter_number));
    } else {
        http_response_code(500);
        echo json_encode(array("success" => false, "message" => "Failed to create chapter: " . $stmt_insert->error));
    }

    $stmt_insert->close();
}

// Jangan lupa menutup koneksi di akhir
$conn->close();
?>