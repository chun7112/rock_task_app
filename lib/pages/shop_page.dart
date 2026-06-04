import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopPage extends StatefulWidget {
  final int points;
  final Function(int) onPointsChanged;
  final Function(String?, String?, String?, String?, String?, String?) onEquip;
  final String? equippedRock;
  final String? equippedHat;
  final String? equippedEyes;
  final String? equippedNeck;
  final String? equippedBody;
  final String? equippedBg;
  final Widget Function(int) buildPoint;

  const ShopPage({
    super.key,
    required this.points,
    required this.onPointsChanged,
    required this.onEquip,
    required this.buildPoint,
    this.equippedRock,
    this.equippedHat,
    this.equippedEyes,
    this.equippedNeck,
    this.equippedBody,
    this.equippedBg,
  });

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<String> ownedItems = [];

  Future<void> saveOwnedItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ownedItems', ownedItems);
  }

  String selectedCategory = "all"; // 👈 目前分類

  Future<void> loadOwnedItems() async {
    final prefs = await SharedPreferences.getInstance();
    ownedItems = prefs.getStringList('ownedItems') ?? [];
    setState(() {});
  }

  List<Map<String, dynamic>> shopItems = [
    

    // ===== 石頭 =====
    {
      "id": "rock02",
      "name": "火山岩",
      "type": "rock",
      "price": 300,
      "image": "assets/rock/rock02.png",
      "previewImage": "assets/rock/rock02.png",
      "lockedImage": "assets/lock_rock/rock02_lock.png",
    },
    {
      "id": "rock03",
      "name": "鵝卵石",
      "type": "rock",
      "price": 300,
      "image": "assets/rock/rock03.png",
      "previewImage": "assets/rock/rock03.png",
      "lockedImage": "assets/lock_rock/rock03_lock.png",
    },
    {
      "id": "rock04",
      "name": "玉石",
      "type": "rock",
      "price": 300,
      "image": "assets/rock/rock04.png",
      "previewImage": "assets/rock/rock04.png",
      "lockedImage": "assets/lock_rock/rock04_lock.png",
    },
    {
      "id": "rock05",
      "name": "琥珀石",
      "type": "rock",
      "price": 300,
      "image": "assets/rock/rock05.png",
      "previewImage": "assets/rock/rock05.png",
      "lockedImage": "assets/lock_rock/rock05_lock.png",
    },
    
    // ===== 帽子 =====
    {
      "id": "hat1",
      "name": "沒有蝦兵但有蟹將",
      "type": "hat",
      "price": 500,
      "image": "assets/hat/hat01.png",
      "previewImage": "assets/shop_hat/hat01_shop.png",
      "lockedImage": "assets/lock_hat/hat01_lock.png",
    },

    // ===== 脖子 =====
    

    // ===== 身體 =====
    {
      "id": "body01",
      "name": "合法合規",
      "type": "body",
      "price": 500,
      "image": "assets/body/body01.png",
      "previewImage": "assets/shop_body/body01_shop.png",
      "lockedImage": "assets/lock_body/body01_lock.png",
    },
    {
      "id": "body02",
      "name": "亞當！！",
      "type": "body",
      "price": 500,
      "image": "assets/body/body02.png",
      "previewImage": "assets/shop_body/body02_shop.png",
      "lockedImage": "assets/lock_body/body02_lock.png",
    },
    {
      "id": "body03",
      "name": "小黃上工",
      "type": "body",
      "price": 500,
      "image": "assets/body/body03.png",
      "previewImage": "assets/shop_body/body03_shop.png",
      "lockedImage": "assets/lock_body/body03_lock.png",
    },
    {
      "id": "body04",
      "name": "小藍上工",
      "type": "body",
      "price": 500,
      "image": "assets/body/body04.png",
      "previewImage": "assets/shop_body/body04_shop.png",
      "lockedImage": "assets/lock_body/body04_lock.png",
    },

    // ===== 眼睛 =====
    {
      "id": "eyes01",
      "name": "地震我看得見",
      "type": "eyes",
      "price": 500,
      "image": "assets/eyes/eyes01.png",
      "previewImage": "assets/shop_eyes/eyes01_shop.png",
      "lockedImage": "assets/lock_eyes/eyes01_lock.png",
    },
    {
      "id": "eyes02",
      "name": "睡美人",
      "type": "eyes",
      "price": 500,
      "image": "assets/eyes/eyes02.png",
      "previewImage": "assets/shop_eyes/eyes02_shop.png",
      "lockedImage": "assets/lock_eyes/eyes02_lock.png",
    },
    // ===== 背景 =====
    {
      "id": "bg01",
      "name": "Checkmate??",
      "type": "bg",
      "price": 500,
      "image": "assets/bg/bg01.png",
      "previewImage": "assets/shop_bg/bg01_shop.png",
      "lockedImage": "assets/lock_bg/bg01_lock.png",
    },
    {
      "id": "bg02",
      "name": "Boooom",
      "type": "bg",
      "price": 500,
      "image": "assets/bg/bg02.png",
      "previewImage": "assets/shop_bg/bg02_shop.png",
      "lockedImage": "assets/lock_bg/bg02_lock.png",
    },

  ];

  void buyItem(String id, int price) {
    // 點數不足
    if (widget.points < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("點數不足", style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 1),
          backgroundColor: Color.fromARGB(255, 239, 74, 20),
        ),
      );
      return;
    }

    // 正常購買
    if (!ownedItems.contains(id)) {
      setState(() {
        ownedItems.add(id);
      });

      saveOwnedItems();

      widget.onPointsChanged(widget.points - price);

      // 成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("購買成功 🎉"),
          duration: Duration(milliseconds: 800),
        ),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredItems() {
    if (selectedCategory == "all") return shopItems;

    return shopItems.where((item) {
      return item["type"] == selectedCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    loadOwnedItems(); // 載入存的資料
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text("商店")),
      body: Column(
        children: [
          // 分類按鈕
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 分類資料
                  ...[
                    {"key": "all", "label": "全部"},
                    {"key": "rock", "label": "石頭"},
                    {"key": "hat", "label": "帽子"},
                    {"key": "eyes", "label": "眼睛"},
                    {"key": "neck", "label": "脖子"},
                    {"key": "body", "label": "身體"},
                    {"key": "bg", "label": "背景"},
                  ].map((category) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: buildCategoryButton(
                        category["key"]!,
                        category["label"]!,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // ===== 商品列表 =====
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width * 0.05,
                vertical: 10,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 一排2個
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75, // 卡片比例
              ),
              itemCount: getFilteredItems().length,
              itemBuilder: (context, index) {
                var item = getFilteredItems()[index];
                bool owned = ownedItems.contains(item["id"]);

                bool isEquipped = false;

                if (item["type"] == "rock") {
                  isEquipped = widget.equippedRock == item["image"];
                } else if (item["type"] == "hat") {
                  isEquipped = widget.equippedHat == item["image"];
                } else if (item["type"] == "eyes") {
                  isEquipped = widget.equippedEyes == item["image"];
                } else if (item["type"] == "neck") {
                  isEquipped = widget.equippedNeck == item["image"];
                } else if (item["type"] == "body") {
                  isEquipped = widget.equippedBody == item["image"];
                } else if (item["type"] == "bg") {
                  isEquipped = widget.equippedBg == item["image"];
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isEquipped
                          ? const Color.fromARGB(255, 246, 184, 69)
                          : Colors.black,
                      width: isEquipped ? 4 : 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: isEquipped
                        ? const Color.fromARGB(
                            255,
                            249,
                            241,
                            135,
                          ).withOpacity(0.1)
                        : null,
                  ),
                  padding: EdgeInsets.all(8),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEquipped)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            color: const Color.fromARGB(255, 246, 158, 4),
                            child: Text(
                              "裝備中",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                      // 圖片
                      Flexible(
                        child: Image.asset(
                          owned
                              ? (item["previewImage"] ?? item["image"])
                              : (item["lockedImage"] ?? "assets/ui/locked.png"),
                          fit: BoxFit.contain,
                        ),
                      ),

                      // 名稱
                      Text(item["name"] ?? item["id"]),

                      // 價格
                      Text("${item["price"]} pt"),

                      // 按鈕
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),

                        onPressed: () async {
                          if (!owned) {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  // 標題置中
                                  title: Center(
                                    child: Text(
                                      item["name"],
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // 商品價格（只有 icon + 數字）
                                      widget.buildPoint(item["price"]),

                                      SizedBox(height: 10),

                                      // 當前點數
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "目前持有 ",
                                            style: TextStyle(
                                              fontSize: 14,
                                              // color: const Color.fromARGB(255, 81, 81, 81),
                                            ),
                                          ),
                                          widget.buildPoint(widget.points),
                                        ],
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 左邊：取消
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: Text("取消"),
                                        ),

                                        // 右邊：購買
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: Text("購買"),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );

                            // 
                            if (confirm == true) {
                              buyItem(item["id"], item["price"]);
                            }
                          } else {
                            // 已裝備 → 卸下
                            if (isEquipped) {
                              if (item["type"] == "rock") {
                                widget.onEquip(
                                  "assets/rock/rock01.png",
                                  widget.equippedHat,
                                  widget.equippedEyes,
                                  widget.equippedNeck,
                                  widget.equippedBody,
                                  widget.equippedBg,
                                );
                              } else if (item["type"] == "hat") {
                                widget.onEquip(
                                  widget.equippedRock,
                                  null,
                                  widget.equippedEyes,
                                  widget.equippedNeck,
                                  widget.equippedBody,
                                  widget.equippedBg,
                                );
                              } else if (item["type"] == "eyes") {
                                widget.onEquip(
                                  widget.equippedRock,
                                  widget.equippedHat,
                                  null,
                                  widget.equippedNeck,
                                  widget.equippedBody,
                                  widget.equippedBg,
                                );
                              } else if (item["type"] == "neck") {
                                widget.onEquip(
                                  widget.equippedRock,
                                  widget.equippedHat,
                                  widget.equippedEyes,
                                  null,
                                  widget.equippedBody,
                                  widget.equippedBg,
                                );
                              } else if (item["type"] == "body") {
                                widget.onEquip(
                                  widget.equippedRock,
                                  widget.equippedHat,
                                  widget.equippedEyes,
                                  widget.equippedNeck,
                                  null,
                                  widget.equippedBg,
                                );
                              } else if (item["type"] == "bg") {
                                widget.onEquip(
                                  widget.equippedRock,
                                  widget.equippedHat,
                                  widget.equippedEyes,
                                  widget.equippedNeck,
                                  widget.equippedBody,
                                  null,
                                );
                              }

                              return;
                            }

                            // 裝備
                            if (item["type"] == "rock") {
                              widget.onEquip(
                                item["image"],
                                widget.equippedHat,
                                widget.equippedEyes,
                                widget.equippedNeck,
                                widget.equippedBody,
                                widget.equippedBg,
                              );
                            } else if (item["type"] == "hat") {
                              widget.onEquip(
                                widget.equippedRock,
                                item["image"],
                                widget.equippedEyes,
                                widget.equippedNeck,
                                widget.equippedBody,
                                widget.equippedBg,
                              );
                            } else if (item["type"] == "eyes") {
                              widget.onEquip(
                                widget.equippedRock,
                                widget.equippedHat,
                                item["image"],
                                widget.equippedNeck,
                                widget.equippedBody,
                                widget.equippedBg,
                              );
                            } else if (item["type"] == "neck") {
                              widget.onEquip(
                                widget.equippedRock,
                                widget.equippedHat,
                                widget.equippedEyes,
                                item["image"],
                                widget.equippedBody,
                                widget.equippedBg,
                              );
                            } else if (item["type"] == "body") {
                              widget.onEquip(
                                widget.equippedRock,
                                widget.equippedHat,
                                widget.equippedEyes,
                                widget.equippedNeck,
                                item["image"],
                                widget.equippedBg,
                              );
                            } else if (item["type"] == "bg") {
                              widget.onEquip(
                                widget.equippedRock,
                                widget.equippedHat,
                                widget.equippedEyes,
                                widget.equippedNeck,
                                widget.equippedBody,
                                item["image"],
                              );
                            }
                          }
                        },
                        child: Text(
                          !owned
                              ? "購買"
                              : isEquipped
                              ? "卸下"
                              : "裝備",
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryButton(String type, String label) {
    bool isSelected = selectedCategory == type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: SizedBox(
        height: 34,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color.fromARGB(255, 255, 200, 80)
                : const Color.fromARGB(255, 255, 244, 222),
            foregroundColor: isSelected ? Colors.white : Colors.black,

            padding: EdgeInsets.symmetric(horizontal: 16), 
            minimumSize: Size(0, 0), 
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
          ),
          onPressed: () {
            setState(() {
              selectedCategory = type;
            });
          },
          child: Text(
            label,
            style: TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
