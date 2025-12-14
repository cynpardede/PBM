<?php
// Pengaturan Koneksi Database
$servername = "localhost";
$username = "root"; // Username default Laragon
$password = "";     // Password default Laragon (kosong)
$dbname = "seebook";

// Membuat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    // Memberikan response error dalam format JSON jika koneksi gagal
    header('Content-Type: application/json');
    http_response_code(500); // Internal Server Error
    echo json_encode(array("success" => false, "message" => "Connection failed: " . $conn->connect_error));
    die();
}

// Set header agar Flutter menerima respons dalam format JSON
header('Content-Type: application/json');

// Catatan: Pastikan Anda menjalankan Laragon agar koneksi ini berhasil.
?>