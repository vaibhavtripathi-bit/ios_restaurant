import Foundation
import CoreLocation

final class MockDataSource: Sendable {
    static let shared = MockDataSource()
    
    private init() {}
    
    // MARK: - Categories
    
    let categories: [Category] = [
        Category(id: "cat-001", name: "Appetizers", imageURL: nil, itemCount: 6, displayOrder: 1),
        Category(id: "cat-002", name: "Salads", imageURL: nil, itemCount: 4, displayOrder: 2),
        Category(id: "cat-003", name: "Pasta", imageURL: nil, itemCount: 5, displayOrder: 3),
        Category(id: "cat-004", name: "Pizza", imageURL: nil, itemCount: 4, displayOrder: 4),
        Category(id: "cat-005", name: "Mains", imageURL: nil, itemCount: 6, displayOrder: 5),
        Category(id: "cat-006", name: "Desserts", imageURL: nil, itemCount: 4, displayOrder: 6),
        Category(id: "cat-007", name: "Drinks", imageURL: nil, itemCount: 5, displayOrder: 7)
    ]
    
    // MARK: - Menu Items
    
    let menuItems: [MenuItem] = [
        // Appetizers
        MenuItem(
            id: "item-001",
            name: "Bruschetta Classica",
            description: "Grilled bread topped with fresh tomatoes, basil, garlic, and extra virgin olive oil",
            price: 8.99,
            imageURL: nil,
            categoryId: "cat-001",
            isVegetarian: true,
            isVegan: true,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 250,
            preparationTime: 10,
            ingredients: ["Ciabatta bread", "Roma tomatoes", "Fresh basil", "Garlic", "Olive oil", "Balsamic glaze"],
            allergens: ["Gluten"]
        ),
        MenuItem(
            id: "item-002",
            name: "Calamari Fritti",
            description: "Crispy fried calamari served with marinara sauce and lemon aioli",
            price: 14.99,
            imageURL: nil,
            categoryId: "cat-001",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 420,
            preparationTime: 12,
            ingredients: ["Calamari", "Flour", "Marinara sauce", "Lemon", "Aioli"],
            allergens: ["Gluten", "Shellfish", "Eggs"]
        ),
        MenuItem(
            id: "item-003",
            name: "Caprese Salad",
            description: "Fresh mozzarella, vine-ripened tomatoes, and basil drizzled with balsamic reduction",
            price: 12.99,
            imageURL: nil,
            categoryId: "cat-001",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 280,
            preparationTime: 8,
            ingredients: ["Fresh mozzarella", "Tomatoes", "Fresh basil", "Balsamic reduction", "Olive oil"],
            allergens: ["Dairy"]
        ),
        MenuItem(
            id: "item-004",
            name: "Arancini",
            description: "Crispy risotto balls stuffed with mozzarella and peas, served with marinara",
            price: 10.99,
            imageURL: nil,
            categoryId: "cat-001",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 380,
            preparationTime: 15,
            ingredients: ["Arborio rice", "Mozzarella", "Peas", "Parmesan", "Breadcrumbs"],
            allergens: ["Gluten", "Dairy"]
        ),
        MenuItem(
            id: "item-005",
            name: "Spicy Meatballs",
            description: "House-made beef and pork meatballs in spicy tomato sauce with crusty bread",
            price: 11.99,
            imageURL: nil,
            categoryId: "cat-001",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .medium,
            calories: 450,
            preparationTime: 12,
            ingredients: ["Beef", "Pork", "Tomato sauce", "Chili flakes", "Crusty bread"],
            allergens: ["Gluten", "Dairy"]
        ),
        MenuItem(
            id: "item-006",
            name: "Garlic Bread",
            description: "Toasted ciabatta with garlic butter and herbs",
            price: 6.99,
            imageURL: nil,
            categoryId: "cat-001",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 220,
            preparationTime: 8,
            ingredients: ["Ciabatta bread", "Butter", "Garlic", "Parsley"],
            allergens: ["Gluten", "Dairy"]
        ),
        
        // Salads
        MenuItem(
            id: "item-007",
            name: "Caesar Salad",
            description: "Crisp romaine, house-made Caesar dressing, parmesan, and garlic croutons",
            price: 11.99,
            imageURL: nil,
            categoryId: "cat-002",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 320,
            preparationTime: 8,
            ingredients: ["Romaine lettuce", "Caesar dressing", "Parmesan", "Croutons"],
            allergens: ["Gluten", "Dairy", "Eggs", "Fish"]
        ),
        MenuItem(
            id: "item-008",
            name: "Mediterranean Salad",
            description: "Mixed greens, olives, feta, cucumber, tomatoes, and lemon vinaigrette",
            price: 13.99,
            imageURL: nil,
            categoryId: "cat-002",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 280,
            preparationTime: 8,
            ingredients: ["Mixed greens", "Kalamata olives", "Feta cheese", "Cucumber", "Cherry tomatoes", "Red onion"],
            allergens: ["Dairy"]
        ),
        MenuItem(
            id: "item-009",
            name: "Grilled Chicken Salad",
            description: "Grilled chicken breast over mixed greens with avocado and honey mustard",
            price: 15.99,
            imageURL: nil,
            categoryId: "cat-002",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 420,
            preparationTime: 12,
            ingredients: ["Chicken breast", "Mixed greens", "Avocado", "Cherry tomatoes", "Honey mustard dressing"],
            allergens: []
        ),
        MenuItem(
            id: "item-010",
            name: "Arugula & Pear Salad",
            description: "Peppery arugula with sliced pears, gorgonzola, walnuts, and balsamic",
            price: 14.99,
            imageURL: nil,
            categoryId: "cat-002",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 340,
            preparationTime: 8,
            ingredients: ["Arugula", "Pears", "Gorgonzola", "Candied walnuts", "Balsamic dressing"],
            allergens: ["Dairy", "Tree nuts"]
        ),
        
        // Pasta
        MenuItem(
            id: "item-011",
            name: "Spaghetti Carbonara",
            description: "Classic Roman pasta with pancetta, egg, pecorino, and black pepper",
            price: 18.99,
            imageURL: nil,
            categoryId: "cat-003",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 680,
            preparationTime: 15,
            ingredients: ["Spaghetti", "Pancetta", "Egg yolks", "Pecorino Romano", "Black pepper"],
            allergens: ["Gluten", "Dairy", "Eggs"]
        ),
        MenuItem(
            id: "item-012",
            name: "Fettuccine Alfredo",
            description: "Silky fettuccine in creamy parmesan sauce with a hint of nutmeg",
            price: 17.99,
            imageURL: nil,
            categoryId: "cat-003",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 720,
            preparationTime: 12,
            ingredients: ["Fettuccine", "Heavy cream", "Parmesan", "Butter", "Nutmeg"],
            allergens: ["Gluten", "Dairy"]
        ),
        MenuItem(
            id: "item-013",
            name: "Penne Arrabbiata",
            description: "Penne in a spicy tomato sauce with garlic and fresh parsley",
            price: 15.99,
            imageURL: nil,
            categoryId: "cat-003",
            isVegetarian: true,
            isVegan: true,
            isGlutenFree: false,
            spicyLevel: .hot,
            calories: 520,
            preparationTime: 12,
            ingredients: ["Penne", "San Marzano tomatoes", "Garlic", "Chili flakes", "Parsley"],
            allergens: ["Gluten"]
        ),
        MenuItem(
            id: "item-014",
            name: "Lasagna Bolognese",
            description: "Layers of pasta, rich meat sauce, béchamel, and melted mozzarella",
            price: 19.99,
            imageURL: nil,
            categoryId: "cat-003",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 850,
            preparationTime: 20,
            ingredients: ["Pasta sheets", "Beef ragù", "Béchamel", "Mozzarella", "Parmesan"],
            allergens: ["Gluten", "Dairy", "Eggs"]
        ),
        MenuItem(
            id: "item-015",
            name: "Seafood Linguine",
            description: "Linguine with shrimp, mussels, and clams in white wine garlic sauce",
            price: 24.99,
            imageURL: nil,
            categoryId: "cat-003",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .mild,
            calories: 620,
            preparationTime: 18,
            ingredients: ["Linguine", "Shrimp", "Mussels", "Clams", "White wine", "Garlic", "Cherry tomatoes"],
            allergens: ["Gluten", "Shellfish"]
        ),
        
        // Pizza
        MenuItem(
            id: "item-016",
            name: "Margherita Pizza",
            description: "San Marzano tomatoes, fresh mozzarella, basil, and olive oil",
            price: 16.99,
            imageURL: nil,
            categoryId: "cat-004",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 720,
            preparationTime: 15,
            ingredients: ["Pizza dough", "San Marzano tomatoes", "Fresh mozzarella", "Basil", "Olive oil"],
            allergens: ["Gluten", "Dairy"]
        ),
        MenuItem(
            id: "item-017",
            name: "Pepperoni Pizza",
            description: "Classic pepperoni with mozzarella and our house tomato sauce",
            price: 18.99,
            imageURL: nil,
            categoryId: "cat-004",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .mild,
            calories: 880,
            preparationTime: 15,
            ingredients: ["Pizza dough", "Tomato sauce", "Mozzarella", "Pepperoni"],
            allergens: ["Gluten", "Dairy"]
        ),
        MenuItem(
            id: "item-018",
            name: "Quattro Formaggi",
            description: "Four cheese pizza with mozzarella, gorgonzola, fontina, and parmesan",
            price: 19.99,
            imageURL: nil,
            categoryId: "cat-004",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 920,
            preparationTime: 15,
            ingredients: ["Pizza dough", "Mozzarella", "Gorgonzola", "Fontina", "Parmesan"],
            allergens: ["Gluten", "Dairy"]
        ),
        MenuItem(
            id: "item-019",
            name: "Diavola Pizza",
            description: "Spicy salami, chili oil, mozzarella, and fresh jalapeños",
            price: 19.99,
            imageURL: nil,
            categoryId: "cat-004",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .hot,
            calories: 860,
            preparationTime: 15,
            ingredients: ["Pizza dough", "Tomato sauce", "Mozzarella", "Spicy salami", "Jalapeños", "Chili oil"],
            allergens: ["Gluten", "Dairy"]
        ),
        
        // Mains
        MenuItem(
            id: "item-020",
            name: "Chicken Parmesan",
            description: "Breaded chicken cutlet with marinara and melted mozzarella, served with spaghetti",
            price: 22.99,
            imageURL: nil,
            categoryId: "cat-005",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 920,
            preparationTime: 20,
            ingredients: ["Chicken breast", "Breadcrumbs", "Marinara", "Mozzarella", "Spaghetti"],
            allergens: ["Gluten", "Dairy", "Eggs"]
        ),
        MenuItem(
            id: "item-021",
            name: "Grilled Salmon",
            description: "Atlantic salmon with lemon herb butter, served with roasted vegetables",
            price: 26.99,
            imageURL: nil,
            categoryId: "cat-005",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 580,
            preparationTime: 18,
            ingredients: ["Atlantic salmon", "Lemon", "Herbs", "Butter", "Seasonal vegetables"],
            allergens: ["Fish", "Dairy"]
        ),
        MenuItem(
            id: "item-022",
            name: "Veal Piccata",
            description: "Tender veal medallions in lemon caper sauce with angel hair pasta",
            price: 28.99,
            imageURL: nil,
            categoryId: "cat-005",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 680,
            preparationTime: 20,
            ingredients: ["Veal", "Lemon", "Capers", "White wine", "Angel hair pasta"],
            allergens: ["Gluten", "Dairy"]
        ),
        MenuItem(
            id: "item-023",
            name: "Eggplant Parmesan",
            description: "Layers of breaded eggplant, marinara, and mozzarella with side salad",
            price: 18.99,
            imageURL: nil,
            categoryId: "cat-005",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 620,
            preparationTime: 20,
            ingredients: ["Eggplant", "Breadcrumbs", "Marinara", "Mozzarella", "Parmesan"],
            allergens: ["Gluten", "Dairy", "Eggs"]
        ),
        MenuItem(
            id: "item-024",
            name: "Ribeye Steak",
            description: "12oz grilled ribeye with garlic herb butter and truffle fries",
            price: 34.99,
            imageURL: nil,
            categoryId: "cat-005",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 980,
            preparationTime: 25,
            ingredients: ["Ribeye steak", "Garlic", "Herbs", "Butter", "Truffle fries"],
            allergens: ["Dairy"]
        ),
        MenuItem(
            id: "item-025",
            name: "Osso Buco",
            description: "Braised veal shank in white wine and vegetables, served with risotto",
            price: 32.99,
            imageURL: nil,
            categoryId: "cat-005",
            isVegetarian: false,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 780,
            preparationTime: 30,
            ingredients: ["Veal shank", "White wine", "Vegetables", "Gremolata", "Risotto"],
            allergens: ["Dairy"]
        ),
        
        // Desserts
        MenuItem(
            id: "item-026",
            name: "Tiramisu",
            description: "Classic Italian dessert with espresso-soaked ladyfingers and mascarpone cream",
            price: 9.99,
            imageURL: nil,
            categoryId: "cat-006",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 450,
            preparationTime: 5,
            ingredients: ["Ladyfingers", "Mascarpone", "Espresso", "Cocoa powder", "Marsala wine"],
            allergens: ["Gluten", "Dairy", "Eggs"]
        ),
        MenuItem(
            id: "item-027",
            name: "Panna Cotta",
            description: "Silky vanilla cream topped with fresh berry compote",
            price: 8.99,
            imageURL: nil,
            categoryId: "cat-006",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 380,
            preparationTime: 5,
            ingredients: ["Heavy cream", "Vanilla", "Sugar", "Gelatin", "Mixed berries"],
            allergens: ["Dairy"]
        ),
        MenuItem(
            id: "item-028",
            name: "Cannoli",
            description: "Crispy pastry shells filled with sweet ricotta and chocolate chips",
            price: 7.99,
            imageURL: nil,
            categoryId: "cat-006",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: false,
            spicyLevel: .none,
            calories: 320,
            preparationTime: 5,
            ingredients: ["Pastry shell", "Ricotta", "Powdered sugar", "Chocolate chips", "Pistachios"],
            allergens: ["Gluten", "Dairy"]
        ),
        MenuItem(
            id: "item-029",
            name: "Gelato Trio",
            description: "Three scoops of artisan gelato - ask about today's flavors",
            price: 8.99,
            imageURL: nil,
            categoryId: "cat-006",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 420,
            preparationTime: 5,
            ingredients: ["Milk", "Cream", "Sugar", "Natural flavors"],
            allergens: ["Dairy"]
        ),
        
        // Drinks
        MenuItem(
            id: "item-030",
            name: "Italian Soda",
            description: "Sparkling water with your choice of flavor syrup",
            price: 4.99,
            imageURL: nil,
            categoryId: "cat-007",
            isVegetarian: true,
            isVegan: true,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 120,
            preparationTime: 2,
            ingredients: ["Sparkling water", "Flavor syrup", "Ice"],
            allergens: []
        ),
        MenuItem(
            id: "item-031",
            name: "Espresso",
            description: "Rich Italian espresso, single or double shot",
            price: 3.99,
            imageURL: nil,
            categoryId: "cat-007",
            isVegetarian: true,
            isVegan: true,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 5,
            preparationTime: 3,
            ingredients: ["Espresso beans"],
            allergens: []
        ),
        MenuItem(
            id: "item-032",
            name: "Cappuccino",
            description: "Espresso with steamed milk and foam",
            price: 5.99,
            imageURL: nil,
            categoryId: "cat-007",
            isVegetarian: true,
            isVegan: false,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 120,
            preparationTime: 4,
            ingredients: ["Espresso", "Steamed milk", "Milk foam"],
            allergens: ["Dairy"]
        ),
        MenuItem(
            id: "item-033",
            name: "Limoncello",
            description: "Traditional Italian lemon liqueur, served chilled",
            price: 8.99,
            imageURL: nil,
            categoryId: "cat-007",
            isVegetarian: true,
            isVegan: true,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 160,
            preparationTime: 2,
            ingredients: ["Limoncello"],
            allergens: []
        ),
        MenuItem(
            id: "item-034",
            name: "House Red Wine",
            description: "Glass of our selected Chianti Classico",
            price: 9.99,
            imageURL: nil,
            categoryId: "cat-007",
            isVegetarian: true,
            isVegan: true,
            isGlutenFree: true,
            spicyLevel: .none,
            calories: 125,
            preparationTime: 2,
            ingredients: ["Chianti Classico wine"],
            allergens: ["Sulfites"]
        )
    ]
    
    // MARK: - Restaurant Info
    
    let restaurant = Restaurant(
        name: "La Bella Italia",
        description: "Experience authentic Italian cuisine in the heart of the city. Our family recipes have been passed down through generations, bringing you the true taste of Italy. From hand-made pasta to wood-fired pizzas, every dish is crafted with love and the finest ingredients.",
        address: "123 Main Street, Downtown\nSan Francisco, CA 94102",
        phone: "(415) 555-0123",
        email: "info@labellaitalia.com",
        website: "https://www.labellaitalia.com",
        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        hours: [
            Restaurant.DayHours(day: .monday, openTime: "11:00", closeTime: "22:00"),
            Restaurant.DayHours(day: .tuesday, openTime: "11:00", closeTime: "22:00"),
            Restaurant.DayHours(day: .wednesday, openTime: "11:00", closeTime: "22:00"),
            Restaurant.DayHours(day: .thursday, openTime: "11:00", closeTime: "22:00"),
            Restaurant.DayHours(day: .friday, openTime: "11:00", closeTime: "23:00"),
            Restaurant.DayHours(day: .saturday, openTime: "10:00", closeTime: "23:00"),
            Restaurant.DayHours(day: .sunday, openTime: "10:00", closeTime: "21:00")
        ],
        features: ["Outdoor Seating", "Private Dining", "Full Bar", "Takeout", "Delivery", "Wheelchair Accessible"],
        socialMedia: Restaurant.SocialMedia(instagram: "@labellaitalia", facebook: "LaBellaItaliaSF", twitter: "@labellaitaliasf")
    )
    
    // MARK: - Time Slots
    
    func generateTimeSlots(for date: Date) -> [TimeSlot] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        
        let startHour = isWeekend ? 10 : 11
        let endHour = isWeekend ? 21 : 22
        
        var slots: [TimeSlot] = []
        for hour in startHour..<endHour {
            for minute in stride(from: 0, to: 60, by: 30) {
                let timeString = String(format: "%02d:%02d", hour, minute)
                let isAvailable = Bool.random()
                slots.append(TimeSlot(time: timeString, isAvailable: isAvailable))
            }
        }
        return slots
    }
}
