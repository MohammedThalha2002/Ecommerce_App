class HomePageModel {
  final String title;
  final String imgUrl;
  final String price;
  final String MRP;
  final String offer;

  HomePageModel(
      {required this.title,
      required this.imgUrl,
      required this.price,
      required this.MRP,
      required this.offer});

  factory HomePageModel.fromRTDB(Map<String, dynamic> data) {
    return HomePageModel(
        title: data['title'],
        imgUrl: data['imgUrl'],
        price: data['price'],
        MRP: data['MRP'],
        offer: data['offer']);
  }
}
