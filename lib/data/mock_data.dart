import '../models/med_category.dart';
import '../models/product.dart';

class MockData {
  MockData._();

  static const List<MedCategory> categories = [
    MedCategory(id: 'all', name: 'Все', emoji: '💊'),
    MedCategory(id: 'pain', name: 'Обезболивающие', emoji: '🤕'),
    MedCategory(id: 'cold', name: 'Простуда', emoji: '🤧'),
    MedCategory(id: 'heart', name: 'Сердце', emoji: '❤️'),
    MedCategory(id: 'vitamin', name: 'Витамины', emoji: '🍋'),
    MedCategory(id: 'kids', name: 'Дети', emoji: '🧸'),
  ];

  static const List<Product> products = [
    Product(
      id: 'p1',
      name: 'Парацетамол',
      subtitle: '10 табл · От боли и температуры',
      price: 180,
      emoji: '💊',
      categoryId: 'pain',
      popular: true,
    ),
    Product(
      id: 'p2',
      name: 'Ибупрофен 400',
      subtitle: '20 табл · Противовоспалительное',
      price: 420,
      emoji: '💊',
      categoryId: 'pain',
      popular: true,
    ),
    Product(
      id: 'p3',
      name: 'Амброксол сироп',
      subtitle: '100 мл · От кашля',
      price: 890,
      emoji: '🧴',
      categoryId: 'cold',
      popular: true,
    ),
    Product(
      id: 'p4',
      name: 'Цитрамон П',
      subtitle: '10 табл · От головной боли',
      price: 160,
      emoji: '💊',
      categoryId: 'pain',
      popular: true,
    ),
    Product(
      id: 'p5',
      name: 'Лоратадин',
      subtitle: '10 табл · От аллергии',
      price: 350,
      emoji: '💊',
      categoryId: 'cold',
    ),
    Product(
      id: 'p6',
      name: 'Витамин С 1000',
      subtitle: '20 табл · Укрепляет иммунитет',
      price: 1200,
      emoji: '🍋',
      categoryId: 'vitamin',
    ),
    Product(
      id: 'p7',
      name: 'Корвалол',
      subtitle: '25 мл · Успокоительное для сердца',
      price: 280,
      emoji: '💧',
      categoryId: 'heart',
    ),
    Product(
      id: 'p8',
      name: 'Нурофен',
      subtitle: '10 табл · Обезболивающее',
      price: 650,
      emoji: '💊',
      categoryId: 'pain',
    ),
    Product(
      id: 'p9',
      name: 'Пантопразол',
      subtitle: '14 табл · Для желудка',
      price: 990,
      emoji: '💊',
      categoryId: 'all',
    ),
    Product(
      id: 'p10',
      name: 'Амоксициллин',
      subtitle: '20 капс · Антибиотик',
      price: 1100,
      emoji: '💊',
      categoryId: 'cold',
    ),
    Product(
      id: 'p11',
      name: 'Детский сироп',
      subtitle: '60 мл · Детское от температуры',
      price: 520,
      emoji: '🍼',
      categoryId: 'kids',
    ),
    Product(
      id: 'p12',
      name: 'Аскорбиновая кислота',
      subtitle: '50 драже · Витамин С',
      price: 150,
      emoji: '🍋',
      categoryId: 'vitamin',
    ),
  ];
}
