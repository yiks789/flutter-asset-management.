import '../models/loan_item.dart';

/// Riwayat pinjaman dummy. Semua pinjaman adalah milik pengguna saat ini.
///
/// 12 pinjaman aktif dan 27 pinjaman selesai. Aset BORROWED tambahan tanpa
/// LoanItem aktif diperlakukan sebagai pinjaman pengguna lain.
final List<LoanItem> dummyLoans = <LoanItem>[
  // Dipinjam: Nov 2026.
  LoanItem(
    assetCode: 'AST-003',
    assetName: 'Dell Latitude 5440',
    borrowDate: DateTime(2026, 11, 17, 9, 10),
  ),
  // Dipinjam: Okt 2026.
  LoanItem(
    assetCode: 'AST-010',
    assetName: 'iPhone 13',
    borrowDate: DateTime(2026, 10, 28, 13, 30),
  ),
  LoanItem(
    assetCode: 'AST-023',
    assetName: 'Samsung ViewFinity S8',
    borrowDate: DateTime(2026, 10, 12, 14, 5),
  ),
  LoanItem(
    assetCode: 'AST-006',
    assetName: 'Logitech MX Keys',
    borrowDate: DateTime(2026, 10, 8, 11, 20),
  ),
  LoanItem(
    assetCode: 'AST-018',
    assetName: 'HP EliteBook 840 G9',
    borrowDate: DateTime(2026, 10, 3, 10, 15),
  ),
  // Dipinjam: Sep 2026.
  LoanItem(
    assetCode: 'AST-015',
    assetName: 'Mouse Wireless Dell',
    borrowDate: DateTime(2026, 9, 26, 10, 10),
  ),
  LoanItem(
    assetCode: 'AST-014',
    assetName: 'Keychron K2 Mechanical',
    borrowDate: DateTime(2026, 9, 14, 15, 30),
  ),
  LoanItem(
    assetCode: 'AST-011',
    assetName: 'Samsung Galaxy S23',
    borrowDate: DateTime(2026, 9, 5, 9, 0),
  ),
  // Dipinjam: Agu 2026.
  LoanItem(
    assetCode: 'AST-017',
    assetName: 'Ubiquiti U6 Lite',
    borrowDate: DateTime(2026, 8, 19, 16, 40),
  ),
  LoanItem(
    assetCode: 'AST-016',
    assetName: 'MikroTik RB5009',
    borrowDate: DateTime(2026, 8, 7, 8, 20),
  ),
  // Dipinjam: Jul 2026.
  LoanItem(
    assetCode: 'AST-008',
    assetName: 'ThinkPad L14 Gen 4',
    borrowDate: DateTime(2026, 7, 21, 8, 45),
  ),
  LoanItem(
    assetCode: 'AST-024',
    assetName: 'ThinkPad T14s Gen 4',
    borrowDate: DateTime(2026, 7, 4, 10, 0),
  ),

  // Dikembalikan: Okt 2026.
  LoanItem(
    assetCode: 'AST-002',
    assetName: 'MacBook Air M2',
    borrowDate: DateTime(2026, 10, 5, 10, 0),
    returnDate: DateTime(2026, 10, 20, 16, 45),
  ),
  LoanItem(
    assetCode: 'AST-005',
    assetName: 'Monitor Dell U2723QE',
    borrowDate: DateTime(2026, 10, 11, 9, 30),
    returnDate: DateTime(2026, 10, 17, 15, 10),
  ),
  LoanItem(
    assetCode: 'AST-001',
    assetName: 'ThinkPad X1 Carbon Gen 11',
    borrowDate: DateTime(2026, 10, 2, 8, 15),
    returnDate: DateTime(2026, 10, 9, 17, 5),
  ),
  // Dikembalikan: Jul 2026.
  LoanItem(
    assetCode: 'AST-025',
    assetName: 'iPhone 14',
    borrowDate: DateTime(2026, 7, 20, 11, 0),
    returnDate: DateTime(2026, 7, 27, 14, 20),
  ),
  LoanItem(
    assetCode: 'AST-023',
    assetName: 'Samsung ViewFinity S8',
    borrowDate: DateTime(2026, 7, 15, 8, 40),
    returnDate: DateTime(2026, 7, 22, 16, 0),
  ),
  LoanItem(
    assetCode: 'AST-019',
    assetName: 'Apple Magic Trackpad',
    borrowDate: DateTime(2026, 7, 8, 10, 10),
    returnDate: DateTime(2026, 7, 12, 13, 30),
  ),
  LoanItem(
    assetCode: 'AST-013',
    assetName: 'Dell UltraSharp U2419H',
    borrowDate: DateTime(2026, 7, 3, 9, 0),
    returnDate: DateTime(2026, 7, 10, 11, 45),
  ),
  // Dikembalikan: Jun 2026.
  LoanItem(
    assetCode: 'AST-013',
    assetName: 'Dell UltraSharp U2419H',
    borrowDate: DateTime(2026, 6, 17, 13, 0),
    returnDate: DateTime(2026, 6, 25, 10, 30),
  ),
  LoanItem(
    assetCode: 'AST-005',
    assetName: 'Monitor Dell U2723QE',
    borrowDate: DateTime(2026, 6, 10, 8, 20),
    returnDate: DateTime(2026, 6, 18, 15, 0),
  ),
  LoanItem(
    assetCode: 'AST-001',
    assetName: 'ThinkPad X1 Carbon Gen 11',
    borrowDate: DateTime(2026, 6, 4, 9, 15),
    returnDate: DateTime(2026, 6, 11, 12, 40),
  ),
  // Dikembalikan: Apr 2026.
  LoanItem(
    assetCode: 'AST-025',
    assetName: 'iPhone 14',
    borrowDate: DateTime(2026, 4, 21, 10, 0),
    returnDate: DateTime(2026, 4, 28, 16, 10),
  ),
  LoanItem(
    assetCode: 'AST-023',
    assetName: 'Samsung ViewFinity S8',
    borrowDate: DateTime(2026, 4, 12, 8, 30),
    returnDate: DateTime(2026, 4, 19, 14, 50),
  ),
  LoanItem(
    assetCode: 'AST-019',
    assetName: 'Apple Magic Trackpad',
    borrowDate: DateTime(2026, 4, 3, 11, 20),
    returnDate: DateTime(2026, 4, 9, 15, 25),
  ),
  // Dikembalikan: Feb 2026.
  LoanItem(
    assetCode: 'AST-005',
    assetName: 'Monitor Dell U2723QE',
    borrowDate: DateTime(2026, 2, 16, 9, 0),
    returnDate: DateTime(2026, 2, 23, 13, 15),
  ),
  LoanItem(
    assetCode: 'AST-001',
    assetName: 'ThinkPad X1 Carbon Gen 11',
    borrowDate: DateTime(2026, 2, 5, 8, 45),
    returnDate: DateTime(2026, 2, 12, 17, 0),
  ),
  // Dikembalikan: Des 2025.
  LoanItem(
    assetCode: 'AST-020',
    assetName: 'Proyektor Epson EB-X06',
    borrowDate: DateTime(2025, 12, 10, 8, 0),
    returnDate: DateTime(2025, 12, 22, 15, 30),
  ),
  LoanItem(
    assetCode: 'AST-023',
    assetName: 'Samsung ViewFinity S8',
    borrowDate: DateTime(2025, 12, 14, 10, 30),
    returnDate: DateTime(2025, 12, 21, 16, 45),
  ),
  LoanItem(
    assetCode: 'AST-019',
    assetName: 'Apple Magic Trackpad',
    borrowDate: DateTime(2025, 12, 11, 13, 0),
    returnDate: DateTime(2025, 12, 17, 11, 20),
  ),
  LoanItem(
    assetCode: 'AST-013',
    assetName: 'Dell UltraSharp U2419H',
    borrowDate: DateTime(2025, 12, 2, 9, 20),
    returnDate: DateTime(2025, 12, 8, 14, 0),
  ),
  // Dikembalikan: Nov 2025.
  LoanItem(
    assetCode: 'AST-025',
    assetName: 'iPhone 14',
    borrowDate: DateTime(2025, 11, 18, 10, 0),
    returnDate: DateTime(2025, 11, 26, 15, 40),
  ),
  LoanItem(
    assetCode: 'AST-005',
    assetName: 'Monitor Dell U2723QE',
    borrowDate: DateTime(2025, 11, 13, 8, 30),
    returnDate: DateTime(2025, 11, 20, 12, 10),
  ),
  LoanItem(
    assetCode: 'AST-001',
    assetName: 'ThinkPad X1 Carbon Gen 11',
    borrowDate: DateTime(2025, 11, 4, 9, 0),
    returnDate: DateTime(2025, 11, 11, 16, 30),
  ),
  // Dikembalikan: Sep 2025.
  LoanItem(
    assetCode: 'AST-019',
    assetName: 'Apple Magic Trackpad',
    borrowDate: DateTime(2025, 9, 19, 11, 0),
    returnDate: DateTime(2025, 9, 25, 14, 45),
  ),
  LoanItem(
    assetCode: 'AST-013',
    assetName: 'Dell UltraSharp U2419H',
    borrowDate: DateTime(2025, 9, 5, 8, 20),
    returnDate: DateTime(2025, 9, 12, 13, 5),
  ),
  // Dikembalikan: Mei 2025.
  LoanItem(
    assetCode: 'AST-005',
    assetName: 'Monitor Dell U2723QE',
    borrowDate: DateTime(2025, 5, 21, 10, 15),
    returnDate: DateTime(2025, 5, 27, 15, 0),
  ),
  LoanItem(
    assetCode: 'AST-002',
    assetName: 'MacBook Air M2',
    borrowDate: DateTime(2025, 5, 12, 9, 0),
    returnDate: DateTime(2025, 5, 19, 11, 20),
  ),
  LoanItem(
    assetCode: 'AST-001',
    assetName: 'ThinkPad X1 Carbon Gen 11',
    borrowDate: DateTime(2025, 5, 6, 8, 40),
    returnDate: DateTime(2025, 5, 13, 12, 30),
  ),
];
