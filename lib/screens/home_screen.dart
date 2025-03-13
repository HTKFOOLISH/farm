import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges; // Import thư viện badges để hiển thị icon thông báo có dấu hiệu (badge)
import '../widgets/custom_button.dart'; // Import widget CustomButton được tùy chỉnh
import '../features/nktt/field_lot_screen.dart'; // Import màn hình "Nhật ký trồng trọt (NKTT)"
import '../features/txng/create_qr_screen.dart'; // Import màn hình "Tạo QR Code"
import '../features/txng/scan_qr_screen.dart'; // Import màn hình "Quét QR Code"

/// HomeScreen là widget chính của ứng dụng, sử dụng StatefulWidget để có thể cập nhật giao diện theo trạng thái.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// _HomeScreenState chứa logic và giao diện của HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  // currentPageIndex lưu trữ chỉ số trang hiện tại được hiển thị.
  int currentPageIndex = 0;

  // GlobalKey dùng để quản lý trạng thái của Scaffold, cần thiết cho việc mở Drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Danh sách các trang có thể hiển thị trong body của Scaffold.
  final List<Widget> pages = [
    const HomeMenu(), // Trang chính chứa các nút chuyển hướng
    const FieldLotScreen(),
    const CreateQRScreen(),
    const ScanQRScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Gán GlobalKey cho Scaffold để quản lý
      drawer: const Drawer(), // Drawer bên trái của ứng dụng
      appBar: AppBar(
        centerTitle: false,
        // Nút mở Drawer, sử dụng IconButton.filledTonal cho giao diện nổi bật
        leading: IconButton.filledTonal(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu),
        ),
        // Tiêu đề của AppBar gồm hai dòng text
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng đầu hiển thị lời chào
            Text("Hi, there! 👋🏿", style: Theme.of(context).textTheme.titleMedium),
            // Dòng thứ hai hiển thị lời chào mừng
            Text("Welcome to Farming App 🌱", style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        backgroundColor: Colors.green.shade700, // Màu nền của AppBar
        actions: [
          // Icon thông báo được bọc trong Padding
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton.filledTonal(
              onPressed: () {}, // Chưa có xử lý khi nhấn vào icon
              icon: badges.Badge(
                // Nội dung badge hiển thị số thông báo
                badgeContent: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
                // Vị trí của badge so với icon
                position: badges.BadgePosition.topEnd(top: -15, end: -12),
                // Kiểu dáng của badge
                badgeStyle: const badges.BadgeStyle(badgeColor: Colors.green),
                child: const Icon(Icons.notifications),
              ),
            ),
          ),
        ],
      ),
      // Body của Scaffold hiển thị trang tương ứng với currentPageIndex
      body: pages[currentPageIndex],
      // BottomNavigationBar cho phép chuyển đổi giữa các trang
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Kiểu cố định khi có nhiều mục
        currentIndex: currentPageIndex, // Chỉ số trang hiện tại được chọn
        onTap: (index) => setState(() => currentPageIndex = index), // Khi nhấn vào mục, cập nhật currentPageIndex và làm mới giao diện
        items: const [
          // Mục "Home" với icon mặc định và active icon khi được chọn
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home", activeIcon: Icon(Icons.home)),
          // Mục "NKTT" tương ứng với màn hình nhật ký trồng trọt
          BottomNavigationBarItem(icon: Icon(Icons.agriculture_outlined), label: "NKTT", activeIcon: Icon(Icons.agriculture)),
          // Mục "Tạo QR" tương ứng với màn hình tạo QR Code
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_2_outlined), label: "Tạo QR", activeIcon: Icon(Icons.qr_code_2)),
          // Mục "Quét QR" tương ứng với màn hình quét QR Code
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_outlined), label: "Quét QR", activeIcon: Icon(Icons.qr_code_scanner)),
        ],
      ),
    );
  }
}

/// HomeMenu là widget hiển thị trang chính với các nút chuyển hướng.
class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDFFFD6), Color(0xFFA7E8A1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        // IntrinsicWidth giúp tất cả CustomButton có cùng chiều rộng
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 350,
                child: CustomButton(
                  text: 'Nhật ký trồng trọt (NKTT)',
                  icon: Icons.agriculture,
                  onPressed: () => homeScreenState?.setState(() {
                    homeScreenState.currentPageIndex = 1;
                  }),
                ),
              ),
              const SizedBox(height: 100),
              SizedBox(
                height: 100,
                width: 350,
                child: CustomButton(
                  text: 'Tạo QR Code',
                  icon: Icons.qr_code_2,
                  onPressed: () => homeScreenState?.setState(() {
                    homeScreenState.currentPageIndex = 2;
                  }),
                ),
              ),
              const SizedBox(height: 100),
              SizedBox(
                height: 100,
                width: 350,
                child: CustomButton(
                  text: 'Quét QR Code',
                  icon: Icons.qr_code_scanner,
                  onPressed: () => homeScreenState?.setState(() {
                    homeScreenState.currentPageIndex = 3;
                  }),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
