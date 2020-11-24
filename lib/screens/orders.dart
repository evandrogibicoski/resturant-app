import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  Orders({Key key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  User user = FirebaseAuth.instance.currentUser;
  final firestoreInstance = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Map> restaurants = [];
  List<Map> orders = [];
  Map restaurantMap = new Map();
  bool isLoading;

  fetchOrders() async {
    var ordersRef = FirebaseFirestore.instance.collection("orders");
    var query = await ordersRef.where("userId", isEqualTo: user.uid).get();
    var orderSnapShotList = query.docs;
    print("order snapshotlist");
    print(orderSnapShotList);
    for (int i = 0; i < orderSnapShotList.length; i++) {
      Map temp = orderSnapShotList[i].data();
      String timeStamp = temp["timestamp"];
      String formattedTimestamp = "";
      for (int i = 0; i < timeStamp.length; i++) {
        if (i < 10) formattedTimestamp += timeStamp[i];
        if (i == 10) formattedTimestamp += " ";
        if (i > 10 && i < 16) formattedTimestamp += timeStamp[i];
        if (i == 16) {
          formattedTimestamp += " Hrs";
          break;
        }
      }
      temp["timestamp"] = formattedTimestamp;
      orders.add(temp);
    }
    print(orders);
    setState(() {

      isLoading = false;
    });
  }

  fetchRestaurantNames() async {
    var restaurantsRef = FirebaseFirestore.instance.collection("restaurants");
    var query = await restaurantsRef.get();
    var restaurantsSnapShotList = query.docs;
    print("Restaurant snapshotlist");
    print(restaurantsSnapShotList);
    for (int i = 0; i < restaurantsSnapShotList.length; i++) {
      Map temp = restaurantsSnapShotList[i].data();
      restaurants.add(temp);
    }
    print(restaurants);
    for (int i = 0; i < restaurants.length; i++) {
      restaurantMap[restaurants[i]["id"]] = restaurants[i]["name"];
    }
    print(restaurantMap);
    isLoading = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    isLoading = true;
    super.initState();
    fetchRestaurantNames();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.keyboard_backspace,
        //   ),
        //   onPressed: ()=>Navigator.pop(context),
        // ),
        centerTitle: true,
        title: Text(
          "HISTORIAL DE PEDIDOS", //ORDER HISTORY
        ),
        elevation: 0.0,
        actions: <Widget>[],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.cyan,
          strokeWidth: 5,
        ),
      )
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nombre del restaurante :',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        restaurantMap[orders[index]["restaurantId"]],
                        style:
                        TextStyle(color: Colors.red, fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Column(
                        children: List.generate(
                            orders[index]["order"].length, (i) {
                          return Container(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Nombre : ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 15.0),
                                  child: Text(
                                      orders[index]["order"][i]["name"],
                                      style:
                                      TextStyle(color: Colors.black)),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Cantidad : ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        orders[index]["order"][i]
                                        ["quantity"]
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "Tiempo de la orden : ", //Time
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15.0),
                        child: Text(
                          orders[index]["timestamp"].toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          Text("Modo de pago : ",
                              //Payment Mode
                              style: TextStyle(color: Colors.black)),
                          Text(orders[index]["paymentMode"],
                              //Payment Mode
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Total Amount : ",
                              style: TextStyle(color: Colors.black)),
                          Text('₲' + orders[index]["total"].toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 19.0,
                              )),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Estado : ",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          Text(orders[index]["status"].toString().toUpperCase(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19.0)),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }
}

/*

Card(
                    color: Colors.blue[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Nombre del restaurante",
                              style: TextStyle(color: Colors.red)),
                          Text(restaurantMap[orders[index]["restaurantId"]],
                              style: TextStyle(color: Colors.green)),
                          Column(
                            children: List.generate(
                                orders[index]["order"].length, (i) {
                              return Container(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                            "Nombre :" +
                                                orders[index]["order"][i]
                                                    ["name"],
                                            style:
                                                TextStyle(color: Colors.black)),
                                        Text(
                                            "Cantidad :" +
                                                orders[index]["order"][i]
                                                        ["quantity"]
                                                    .toString(),
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          Text(
                              "Tiempo de la orden:" +
                                  orders[index]["timestamp"].toString(), //Time
                              style: TextStyle(
                                color: Colors.red,
                              )),
                          Text("Modo de pago:" + orders[index]["paymentMode"],
                              //Payment Mode
                              style: TextStyle(color: Colors.green)),
                          Text("Total " + orders[index]["total"].toString(),
                              style: TextStyle(color: Colors.black)),
                          Text(
                            "Estado " + orders[index]["status"],
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
 */
