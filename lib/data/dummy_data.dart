import '../models/category_model.dart';
import '../models/restaurant_model.dart';
import '../models/food_item_model.dart';
import '../models/address_model.dart';

const List<CategoryModel> dummyCategories = [
  CategoryModel(
    id: '1',
    title: 'Pizza',
    icon: '🍕',
  ),
  CategoryModel(
    id: '2',
    title: 'Burger',
    icon: '🍔',
  ),
  CategoryModel(
    id: '3',
    title: 'Sushi',
    icon: '🍣',
  ),
  CategoryModel(
    id: '4',
    title: 'Dessert',
    icon: '🍰',
  ),
  CategoryModel(
    id: '5',
    title: 'Healthy',
    icon: '🥗',
  ),
];

const List<RestaurantModel> dummyRestaurants = [
  RestaurantModel(
    id: 'r1',
    name: 'Nordic Bites',
    category: 'Healthy • Bowls • Salads',
    rating: '4.8',
    deliveryTime: '20-30 min',
    deliveryFee: 'Free delivery',
    imageUrl: '',
    isOpen: true,
  ),
  RestaurantModel(
    id: 'r2',
    name: 'Urban Pizza Co.',
    category: 'Pizza • Italian',
    rating: '4.6',
    deliveryTime: '25-35 min',
    deliveryFee: 'Rs39 delivery',
    imageUrl: '',
    isOpen: true,
  ),
  RestaurantModel(
    id: 'r3',
    name: 'Burger House',
    category: 'Burgers • Fast Food',
    rating: '4.5',
    deliveryTime: '15-25 min',
    deliveryFee: 'Rs29 delivery',
    imageUrl: '',
    isOpen: false,
  ),
];

const List<FoodItemModel> dummyFoodItems = [
  FoodItemModel(
    id: 'f1',
    restaurantId: 'r1',
    name: 'Greek Salad Bowl',
    description: 'Fresh veggies, olives, feta cheese and house dressing.',
    price: 179.0,
    imageUrl: '',
    isVeg: true,
    isAvailable: true,
  ),
  FoodItemModel(
    id: 'f2',
    restaurantId: 'r1',
    name: 'Protein Power Bowl',
    description: 'Healthy bowl with grilled paneer, rice and vegetables.',
    price: 229.0,
    imageUrl: '',
    isVeg: true,
    isAvailable: true,
  ),
  FoodItemModel(
    id: 'f3',
    restaurantId: 'r1',
    name: 'Chicken Caesar Wrap',
    description: 'Grilled chicken, lettuce, caesar sauce and soft wrap.',
    price: 249.0,
    imageUrl: '',
    isVeg: false,
    isAvailable: true,
  ),
  FoodItemModel(
    id: 'f4',
    restaurantId: 'r2',
    name: 'Margherita Pizza',
    description: 'Classic pizza with mozzarella, tomato sauce and basil.',
    price: 249.0,
    imageUrl: '',
    isVeg: true,
    isAvailable: true,
  ),
  FoodItemModel(
    id: 'f5',
    restaurantId: 'r2',
    name: 'Farmhouse Pizza',
    description: 'Loaded with capsicum, onion, tomato, corn and cheese.',
    price: 329.0,
    imageUrl: '',
    isVeg: true,
    isAvailable: true,
  ),
  FoodItemModel(
    id: 'f6',
    restaurantId: 'r2',
    name: 'Pepperoni Pizza',
    description: 'Cheesy pizza topped with spicy pepperoni slices.',
    price: 399.0,
    imageUrl: '',
    isVeg: false,
    isAvailable: true,
  ),
  FoodItemModel(
    id: 'f7',
    restaurantId: 'r3',
    name: 'Classic Chicken Burger',
    description: 'Juicy chicken patty with cheese and fresh veggies.',
    price: 199.0,
    imageUrl: '',
    isVeg: false,
    isAvailable: true,
  ),
  FoodItemModel(
    id: 'f8',
    restaurantId: 'r3',
    name: 'Cheese Burger',
    description: 'Soft bun, crispy patty, cheese slice and special sauce.',
    price: 149.0,
    imageUrl: '',
    isVeg: true,
    isAvailable: true,
  ),
  FoodItemModel(
    id: 'f9',
    restaurantId: 'r3',
    name: 'Double Patty Burger',
    description: 'Double patty burger with extra cheese and sauces.',
    price: 279.0,
    imageUrl: '',
    isVeg: false,
    isAvailable: false,
  ),
];

const List<AddressModel> dummyAddresses = [
  AddressModel(
    id: 'a1',
    title: 'Home',
    fullAddress: 'House No. 24, Green Park Colony, Meerut, Uttar Pradesh',
    phoneNumber: '+91 9876543210',
    isDefault: true,
  ),
  AddressModel(
    id: 'a2',
    title: 'Work',
    fullAddress: 'Office Tower, Sector 62, Noida, Uttar Pradesh',
    phoneNumber: '+91 9876501234',
    isDefault: false,
  ),
  AddressModel(
    id: 'a3',
    title: 'Friend',
    fullAddress: 'Flat 302, Sunshine Apartments, Delhi',
    phoneNumber: '+91 9123456780',
    isDefault: false,
  ),
];