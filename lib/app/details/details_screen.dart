import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:bikestore/app/data/api.dart';
import 'package:bikestore/app/data/sqlite.dart';
import 'package:bikestore/app/model/cart.dart';
import 'package:bikestore/app/model/product.dart';
import 'package:bikestore/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/add_to_cart.dart';
import 'components/color_and_size.dart';
import 'components/counter_with_fav_btn.dart';
import 'components/description.dart';
import 'components/product_title_with_image.dart';

class DetailsScreen extends StatefulWidget {
  final ProductModel product;

  const DetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final DatabaseHelper _databaseService = DatabaseHelper();
  Future<void> _onSave(ProductModel pro) async {
    await _databaseService.insertProduct(Cart(
        productID: pro.id,
        name: pro.name,
        des: pro.description,
        price: pro.price,
        img: pro.imageUrl,
        count: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height,
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.3),
                    padding: EdgeInsets.only(
                      top: size.height * 0.12,
                      left: kDefaultPaddin,
                      right: kDefaultPaddin,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        ColorAndSize(product: widget.product),
                        SizedBox(height: kDefaultPaddin / 2),
                        Description(product: widget.product),
                      //  SizedBox(height: kDefaultPaddin / 2),
                     //   CounterWithFavBtn(),
                        SizedBox(height: kDefaultPaddin / 2),
                        AddToCart(product: widget.product)
                      ],
                    ),
                  ),
                  ProductTitleWithImage(product: widget.product)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}