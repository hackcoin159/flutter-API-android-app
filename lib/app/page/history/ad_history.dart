import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bikestore/app/data/api.dart';
import 'package:bikestore/app/model/bill.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart'; // Import Dio

class ADHistoryScreen extends StatefulWidget {
  const ADHistoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ADHistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<ADHistoryScreen> {
  late Future<List<BillModel>> _futureBills;
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _futureBills = getBillAdminPage();
  }

  Future<List<BillModel>> getBillAdminPage() async {
    try {
      Response res = await Dio().get(
        'https://huflit.id.vn:4321/api/Bill/getHistory',
      );

      // Kiểm tra kiểu dữ liệu của res.data và chuyển đổi nếu cần
      if (res.data is List) {
        return (res.data as List).map((e) => BillModel.fromJson(e)).toList();
      } else {
        throw Exception('Invalid data format');
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<BillModel>>(
        future: _futureBills,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("Không có dữ liệu", style: TextStyle(fontSize: 18)));
          }

          // Paginate the data
          int totalPages = (snapshot.data!.length / _itemsPerPage).ceil();
          List<BillModel> currentPageItems = snapshot.data!
              .skip(_currentPage * _itemsPerPage)
              .take(_itemsPerPage)
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: currentPageItems.length,
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, index) {
                    final itemBill = currentPageItems[index];
                    return _buildBillWidget(itemBill);
                  },
                ),
              ),
              _buildPaginationControls(totalPages),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPage > 0
              ? () => setState(() {
            _currentPage--;
          })
              : null,
        ),
        Text('${_currentPage + 1} / $totalPages'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _currentPage < totalPages - 1
              ? () => setState(() {
            _currentPage++;
          })
              : null,
        ),
      ],
    );
  }

  Widget _buildBillWidget(BillModel bill) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // More rounded corners
      ),
      color: Colors.pink[50], // Light pink background color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Mã đơn hàng: #${bill.id}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[800], // Dark pink text color
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy')
                      .format(DateFormat('dd/MM/yyyy').parse(bill.dateCreated)),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0), // Increased spacing
            Text(
              bill.fullName,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.pink[900], // Darker pink text color
              ),
            ),
            const SizedBox(height: 12.0), // Increased spacing
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Tổng tiền: ${NumberFormat('#,##0').format(bill.total)} VND',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD9369D), // Pink color
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
