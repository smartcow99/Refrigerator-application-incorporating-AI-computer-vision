import 'dart:convert';

import 'package:flutter/services.dart';
import 'dart:async';

Future<String> loadingJson() async {
  return await rootBundle.loadString('assets/recipe.json');
}

Future loadRecipe() async {
  String jsonString = await loadingJson();
  print("This is loadRecipe" + jsonString);
}

class RecipeList {
  static Future<String> getInstance() async {
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

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(name: json['name'], ingre: json['ingre'].cast<String>());
  }

  toJson() => {
        'name': this.name,
        'ingre': this.ingre,
      };
  toString() => "name: $name, ignre: $ingre";
}

List<Recipe> recipeFromJson(String json) {
  List<dynamic> parsedJson = jsonDecode(json);
  print("parsedJson = $parsedJson");
  List<Recipe> recipes = [];
  for (int i = 0; i < parsedJson.length; i++) {
    recipes.add(Recipe.fromJson(parsedJson[i]));
  }
  return recipes;
}

Future readRecipeJson() async {
  final String response = await rootBundle.loadString('assets/recipe.json');
  return recipeFromJson(response);
}

  // 이거 사용할 클래스 내부에서 밑에 함수 + 리스트 선언하고 저 함수 호출하면 recipes로 들어감
  // 근데 비동기여서 처리 잘 해야할듯

  // List<Recipe> recipes = [];

  // Future<void> readRecipeJson() async {
  //   final String response = await rootBundle.loadString('assets/recipe.json');
  //   final data = recipeFromJson(response);
  //   setState(() {
  //     recipes = data;
  //   });
  // }