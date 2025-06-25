// Import thư viện Material Design của Flutter để sử dụng các widget và màu sắc
import 'package:flutter/material.dart';

/// Class chứa các biến toàn cục (constants) được sử dụng trong toàn bộ ứng dụng
/// Giúp duy trì tính nhất quán về màu sắc và thiết kế trong app
class GlobalVariables {
  // =================================================================
  // PHẦN ĐỊNH NGHĨA CÁC MÀU SẮC CHO ỨNG DỤNG
  // =================================================================

  /// Gradient màu cho AppBar (thanh tiêu đề ứng dụng)
  /// LinearGradient: Tạo hiệu ứng chuyển màu tuyến tính từ màu này sang màu khác
  static const appBarGradient = LinearGradient(
    colors: [
      // Màu xanh cyan đậm (ARGB: Alpha=255, Red=29, Green=201, Blue=192)
      Color.fromARGB(255, 29, 201, 192),
      // Màu xanh cyan nhạt hơn (ARGB: Alpha=255, Red=125, Green=221, Blue=216)
      Color.fromARGB(255, 125, 221, 216),
    ],
    // stops: Xác định vị trí các màu trong gradient
    // 0.5 = màu đầu tiên chiếm 50% đầu, 1.0 = màu thứ hai chiếm 50% cuối
    stops: [0.5, 1.0],
  );

  /// Màu phụ của ứng dụng - màu cam
  /// fromRGBO: Red=255, Green=153, Blue=0, Opacity=1 (không trong suốt)
  /// Thường dùng cho các button, accent color
  static const secondaryColor = Color.fromRGBO(255, 153, 0, 1);

  /// Màu nền chính của ứng dụng - màu trắng
  /// Colors.white là màu được định nghĩa sẵn trong Flutter
  static const backgroundColor = Colors.white;

  /// Màu nền xám nhạt cho các phần tử phụ
  /// 0xffebecee: Hexadecimal color code (ff=alpha, ebecee=RGB)
  /// Lưu ý: Có lỗi chính tả "COlor" thay vì "Color"
  static const Color greyBackgroundCOlor = Color(0xffebecee);

  /// Màu cho navigation bar item khi được chọn
  /// Colors.cyan[800]: Sử dụng màu cyan độ đậm level 800
  /// Dấu ! (null assertion): Đảm bảo giá trị không null
  /// Dùng var thay vì const vì Colors.cyan[800] không phải compile-time constant
  static var selectedNavBarColor = Colors.cyan[800]!;

  /// Màu cho navigation bar item khi chưa được chọn
  /// Colors.black87: Màu đen với độ trong suốt 87%
  static const unselectedNavBarColor = Colors.black87;
}
