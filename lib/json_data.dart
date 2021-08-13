import 'package:flutter/services.dart';
import 'dart:async';

Future<String> loadingJson() async{
  return await rootBundle.loadString('assets/recipe.json');
}

Future loadRecipe() async{
  String jsonString = await loadingJson();
  print("This is loadRecipe"+jsonString);
}
class RecipeList {
  static Future<String> getInstance() async{
    String temp = await loadingJson();
    return temp;
  }
  final List<Recipe> recipes;

  RecipeList({
    required this.recipes,
  });

  factory RecipeList.fromJson(List<dynamic> parsedJson) {
    List<Recipe> recipes = [];
    recipes = parsedJson.map((e) => Recipe.fromJson(e)).toList();
    return new RecipeList(
      recipes: recipes,
    );
  }
}

class Recipe {
  late String name;
  late List<String> ingre;

  Recipe({required this.name, required this.ingre});

  Recipe.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    ingre = json['ingre'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['ingre'] = this.ingre;
    return data;
  }
}
