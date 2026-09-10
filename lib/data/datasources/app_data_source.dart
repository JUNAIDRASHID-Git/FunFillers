import '../../domain/entities/user.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/address.dart';

class AppDataSource {
  static const UserEntity demoUser = UserEntity(
    id: 'usr_john_doe',
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+91 9876543210',
    avatarUrl: null,
  );

  static final List<CategoryEntity> mockCategories = [
    const CategoryEntity(
      id: 'cat_action',
      name: 'Action Figures',
      iconImage: 'https://images.unsplash.com/photo-1608889825205-eebdb9fc5806?auto=format&fit=crop&w=200&q=80',
      itemCount: 124,
      subCategories: [
        SubCategoryEntity(id: 'sub_1', categoryId: 'cat_action', name: 'Superheroes', iconImage: 'https://images.unsplash.com/photo-1608889825205-eebdb9fc5806?auto=format&fit=crop&w=200&q=80', description: 'Avengers & Spider-Man'),
        SubCategoryEntity(id: 'sub_2', categoryId: 'cat_action', name: 'Anime Collectibles', iconImage: 'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=200&q=80', description: 'Statues & Figurines'),
      ],
    ),
    const CategoryEntity(
      id: 'cat_dolls',
      name: 'Dolls',
      iconImage: 'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55?auto=format&fit=crop&w=200&q=80',
      itemCount: 98,
      subCategories: [
        SubCategoryEntity(id: 'sub_3', categoryId: 'cat_dolls', name: 'Teddy Bears', iconImage: 'https://images.unsplash.com/photo-1558060370-d644479be6f7?auto=format&fit=crop&w=200&q=80', description: 'Plush & Soft Bears'),
        SubCategoryEntity(id: 'sub_4', categoryId: 'cat_dolls', name: 'Fashion Dolls', iconImage: 'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55?auto=format&fit=crop&w=200&q=80', description: 'Princess & Fashion Dolls'),
      ],
    ),
    const CategoryEntity(
      id: 'cat_building',
      name: 'Building Blocks',
      iconImage: 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=200&q=80',
      itemCount: 76,
      subCategories: [
        SubCategoryEntity(id: 'sub_5', categoryId: 'cat_building', name: 'Wooden Blocks', iconImage: 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=200&q=80', description: 'Educational Wooden Sets'),
        SubCategoryEntity(id: 'sub_6', categoryId: 'cat_building', name: 'Construction Sets', iconImage: 'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=200&q=80', description: 'Lego style bricks'),
      ],
    ),
    const CategoryEntity(
      id: 'cat_vehicles',
      name: 'Vehicles',
      iconImage: 'https://images.unsplash.com/photo-1594787318286-3d835c1d207f?auto=format&fit=crop&w=200&q=80',
      itemCount: 112,
      subCategories: [
        SubCategoryEntity(id: 'sub_7', categoryId: 'cat_vehicles', name: 'RC Cars', iconImage: 'https://images.unsplash.com/photo-1594787318286-3d835c1d207f?auto=format&fit=crop&w=200&q=80', description: 'Remote Stunt Vehicles'),
        SubCategoryEntity(id: 'sub_8', categoryId: 'cat_vehicles', name: 'Diecast Models', iconImage: 'https://images.unsplash.com/photo-1581235720704-06d3acfcb36f?auto=format&fit=crop&w=200&q=80', description: 'Scale Metal Cars'),
      ],
    ),
    const CategoryEntity(
      id: 'cat_educational',
      name: 'Educational',
      iconImage: 'https://images.unsplash.com/photo-1500995617113-cf789362a3e1?auto=format&fit=crop&w=200&q=80',
      itemCount: 64,
      subCategories: [
        SubCategoryEntity(id: 'sub_9', categoryId: 'cat_educational', name: 'STEM Puzzles', iconImage: 'https://images.unsplash.com/photo-1500995617113-cf789362a3e1?auto=format&fit=crop&w=200&q=80', description: 'Logic & Science Kits'),
        SubCategoryEntity(id: 'sub_10', categoryId: 'cat_educational', name: 'Musical Toys', iconImage: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=200&q=80', description: 'Instruments & Guitars'),
      ],
    ),
    const CategoryEntity(
      id: 'cat_outdoor',
      name: 'Outdoor Toys',
      iconImage: 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=200&q=80',
      itemCount: 48,
    ),
  ];

  static final List<ProductEntity> mockProducts = [
    const ProductEntity(
      id: 'prod_teddy_bear',
      title: 'Teddy Bear',
      category: 'Dolls',
      targetGender: 'Girls',
      price: 19.99,
      originalPrice: 29.99,
      discountPercent: 33,
      rating: 4.8,
      reviewCount: 1240,
      description: 'The perfect cuddly companion for your little one. Made with ultra-soft material and 100% safe for kids.',
      mainImage: 'https://images.unsplash.com/photo-1558060370-d644479be6f7?auto=format&fit=crop&w=600&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1558060370-d644479be6f7?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?auto=format&fit=crop&w=600&q=80',
      ],
      isFeatured: true,
      isFavorite: true,
    ),
    const ProductEntity(
      id: 'prod_rc_car',
      title: 'RC Car',
      category: 'Vehicles',
      targetGender: 'Boys',
      price: 24.99,
      originalPrice: 34.99,
      discountPercent: 28,
      rating: 4.7,
      reviewCount: 890,
      description: 'High-speed remote control stunt car with rechargeable battery and 360-degree flip capability.',
      mainImage: 'https://images.unsplash.com/photo-1594787318286-3d835c1d207f?auto=format&fit=crop&w=600&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1594787318286-3d835c1d207f?auto=format&fit=crop&w=600&q=80',
      ],
      isFeatured: true,
      isFavorite: true,
    ),
    const ProductEntity(
      id: 'prod_building_blocks',
      title: 'Building Blocks',
      category: 'Building Blocks',
      targetGender: 'Educational',
      price: 16.99,
      originalPrice: 22.99,
      discountPercent: 26,
      rating: 4.9,
      reviewCount: 1560,
      description: 'Creative rainbow wooden building blocks set. Enhances motor skills, spatial reasoning, and imagination.',
      mainImage: 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=600&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1587654780291-39c9404d746b?auto=format&fit=crop&w=600&q=80',
      ],
      isFeatured: true,
      isFavorite: true,
    ),
    const ProductEntity(
      id: 'prod_doll_princess',
      title: 'Doll Princess',
      category: 'Dolls',
      targetGender: 'Girls',
      price: 22.99,
      originalPrice: 29.99,
      discountPercent: 23,
      rating: 4.6,
      reviewCount: 650,
      description: 'Premium quality royal princess doll with changeble outfits and soft hair brush.',
      mainImage: 'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55?auto=format&fit=crop&w=600&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1566576721346-d4a3b4eaeb55?auto=format&fit=crop&w=600&q=80',
      ],
      isFeatured: true,
      isFavorite: true,
    ),
    const ProductEntity(
      id: 'prod_toy_guitar',
      title: 'Toy Guitar',
      category: 'Educational',
      targetGender: 'Educational',
      price: 18.99,
      originalPrice: 24.99,
      discountPercent: 24,
      rating: 4.8,
      reviewCount: 420,
      description: 'Interactive musical ukulele toy guitar with vibrant lights and melody sound modes.',
      mainImage: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=600&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=600&q=80',
      ],
      isFeatured: false,
      isFavorite: true,
    ),
    const ProductEntity(
      id: 'prod_action_figure',
      title: 'Action Figures',
      category: 'Action Figures',
      targetGender: 'Boys',
      price: 29.99,
      originalPrice: 39.99,
      discountPercent: 25,
      rating: 4.9,
      reviewCount: 2100,
      description: 'Poseable superhero action figure with LED light chest armor and combat accessories.',
      mainImage: 'https://images.unsplash.com/photo-1608889825205-eebdb9fc5806?auto=format&fit=crop&w=600&q=80',
      galleryImages: [
        'https://images.unsplash.com/photo-1608889825205-eebdb9fc5806?auto=format&fit=crop&w=600&q=80',
      ],
      isFeatured: true,
      isFavorite: false,
    ),
  ];

  static final List<AddressEntity> mockAddresses = [];
}
