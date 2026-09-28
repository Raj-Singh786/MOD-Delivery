import Foundation

struct MockData {
    // MARK: - Menu Categories
    static let categories: [MenuCategory] = [
        MenuCategory(id: "cat1", name: "Pizza", description: "Our signature pizzas", sortOrder: 0),
        MenuCategory(id: "cat2", name: "Salads", description: "Fresh and healthy", sortOrder: 1),
        MenuCategory(id: "cat3", name: "Sides", description: "Perfect accompaniments", sortOrder: 2),
        MenuCategory(id: "cat4", name: "Desserts", description: "Sweet treats", sortOrder: 3),
        MenuCategory(id: "cat5", name: "Kids Meals", description: "For little ones", sortOrder: 4),
        MenuCategory(id: "cat6", name: "Beverages", description: "Refreshing drinks", sortOrder: 5),
        MenuCategory(id: "cat7", name: "Extras", description: "Add-ons", sortOrder: 6)
    ]
    
    // MARK: - Menu Items
    static let menuItems: [MenuItem] = [
        MenuItem(
            id: "item1",
            categoryId: "cat1",
            name: "Create Your Own Pizza",
            description: "Customize with 40+ toppings",
            image: "pizza",
            basePrice: 299,
            calories: nil,
            isCustomizable: true,
            isVegetarian: false,
            isSpicy: false,
            isPopular: true,
            isAvailable: true
        ),
        MenuItem(
            id: "item2",
            categoryId: "cat1",
            name: "Mad Dog",
            description: "Pepperoni, mild sausage, mozzarella",
            image: "paper",
            basePrice: 449,
            calories: 620,
            isCustomizable: true,
            isVegetarian: false,
            isSpicy: false,
            isPopular: true,
            isAvailable: true
        ),
        MenuItem(
            id: "item3",
            categoryId: "cat1",
            name: "Caspian",
            description: "Chicken, mozzarella, garlic rub",
            image: "pizza2",
            basePrice: 449,
            calories: 580,
            isCustomizable: true,
            isVegetarian: false,
            isSpicy: false,
            isPopular: false,
            isAvailable: true
        ),
        MenuItem(
            id: "item4",
            categoryId: "cat1",
            name: "Dillon James",
            description: "Pepperoni, mozzarella, red sauce",
            image: "pizza3",
            basePrice: 399,
            calories: 550,
            isCustomizable: true,
            isVegetarian: false,
            isSpicy: false,
            isPopular: true,
            isAvailable: true
        ),
        MenuItem(
            id: "item5",
            categoryId: "cat2",
            name: "Garden Salad",
            description: "Mixed greens, tomatoes, cucumbers",
            image: "salad2",
            basePrice: 199,
            calories: 180,
            isCustomizable: true,
            isVegetarian: true,
            isSpicy: false,
            isPopular: false,
            isAvailable: true
        ),
        MenuItem(
            id: "item6",
            categoryId: "cat3",
            name: "Garlic Bread",
            description: "Crispy bread with garlic butter",
            image: "garlic",
            basePrice: 149,
            calories: 220,
            isCustomizable: false,
            isVegetarian: true,
            isSpicy: false,
            isPopular: true,
            isAvailable: true
        ),
        MenuItem(
            id: "item7",
            categoryId: "cat3",
            name: "Cinnamon Balls",
            description: "Sweet cinnamon sugar bites",
            image: "cine",
            basePrice: 129,
            calories: 280,
            isCustomizable: false,
            isVegetarian: true,
            isSpicy: false,
            isPopular: true,
            isAvailable: true
        ),
        MenuItem(
            id: "item8",
            categoryId: "cat4",
            name: "Chocolate Brownie",
            description: "Rich chocolate brownie",
            image: "brown",
            basePrice: 149,
            calories: 350,
            isCustomizable: false,
            isVegetarian: true,
            isSpicy: false,
            isPopular: false,
            isAvailable: true
        ),
        MenuItem(
            id: "item9",
            categoryId: "cat5",
            name: "Kids Pizza",
            description: "6\" cheese pizza with juice",
            image: "pizza3",
            basePrice: 249,
            calories: 400,
            isCustomizable: true,
            isVegetarian: true,
            isSpicy: false,
            isPopular: false,
            isAvailable: true
        ),
        MenuItem(
            id: "item10",
            categoryId: "cat6",
            name: "pizza4",
            description: "Refreshing soda",
            basePrice: 79,
            calories: 140,
            isCustomizable: false,
            isVegetarian: true,
            isSpicy: false,
            isPopular: false,
            isAvailable: true
        )
    ]
    
    // MARK: - Ingredients
    static let ingredients: [Ingredient] = [
        // Sauces
        Ingredient(id: "sauce1", name: "Tomato Sauce",image: "tomato", category: .sauce, calories: 30, basePrice: 0),
        Ingredient(id: "sauce2", name: "BBQ Sauce",image: "BBQ", category: .sauce, calories: 45, basePrice: 0),
        Ingredient(id: "sauce3", name: "Creamy Alfredo",image: "cream2", category: .sauce, calories: 60, basePrice: 0),
        Ingredient(id: "sauce4", name: "Frank's RedHot Buffalo Sauce",image: "red",category: .sauce, calories: 15, basePrice: 0),
        Ingredient(id: "sauce5", name: "Garlic Rub",image: "Garlic", category: .sauce, calories: 10, basePrice: 0),
        Ingredient(id: "sauce6", name: "Olive Oil",image: "oil", category: .sauce, calories: 40, basePrice: 0),
        Ingredient(id: "sauce7", name: "Pesto",image: "pesto", category: .sauce, calories: 50, basePrice: 0),
        
        // Cheese
        Ingredient(id: "cheese1", name: "Asiago",image: "as", category: .cheese, calories: 65, basePrice: 30),
        Ingredient(id: "cheese2", name: "Cheddar",image: "ch", category: .cheese, calories: 58, basePrice: 25),
        Ingredient(id: "cheese3", name: "Feta",image: "fe", category: .cheese, calories: 45, basePrice: 35),
        Ingredient(id: "cheese4", name: "Gorgonzola",image: "gonz", category: .cheese, calories: 55, basePrice: 30),
        Ingredient(id: "cheese5", name: "Mozzarella",image: "moz", category: .cheese, calories: 40, basePrice: 20),
        Ingredient(id: "cheese6", name: "Parmesan",image: "per", category: .cheese, calories: 60, basePrice: 25),
        Ingredient(id: "cheese7", name: "Plant Based Cheese",image: "plantC", category: .cheese, calories: 57, basePrice: 35),
        Ingredient(id: "cheese8", name: "Ricotta",image: "rico", category: .cheese, calories: 43, basePrice: 30),
        
        // Meats
        Ingredient(id: "meat1", name: "Anchovies", image: "Anchovies", category: .meat, calories: 15, isVegetarian: false, basePrice: 45),
        Ingredient(id: "meat2", name: "Bacon",image: "Bacon", category: .meat, calories: 70, isVegetarian: false, basePrice: 50),
        Ingredient(id: "meat3", name: "Canadian Bacon",image: "CB", category: .meat, calories: 33, isVegetarian: false, basePrice: 45),
        Ingredient(id: "meat4", name: "Grilled Chicken",image: "gc", category: .meat, calories: 38, isVegetarian: false, basePrice: 55),
        Ingredient(id: "meat5", name: "Ground Beef",image: "Bac", category: .meat, calories: 105, isVegetarian: false, basePrice: 60),
        Ingredient(id: "meat6", name: "Mild Italian Sausage",image: "iSas", category: .meat, calories: 120, isVegetarian: false, basePrice: 55),
        Ingredient(id: "meat7", name: "Pepperoni", image: "per", category: .meat, calories: 25, isVegetarian: false, basePrice: 40),
        Ingredient(id: "meat8", name: "Plant Based Italian Sausage",image: "suS", category: .meat, calories: 58, isVegetarian: true, basePrice: 55),
        Ingredient(id: "meat9", name: "Salami",image: "CB", category: .meat, calories: 45, isVegetarian: false, basePrice: 50),
        Ingredient(id: "meat10", name: "Spicy Chicken Sausage",image: "iSas", category: .meat, calories: 85, isVegetarian: false, isSpicy: true, basePrice: 55),
        
        // Vegetables
        Ingredient(id: "veg1", name: "Artichokes",image: "Artichokes", category: .vegetable, calories: 15, basePrice: 30),
        Ingredient(id: "veg2", name: "Arugula", image: "Arugula", category: .vegetable, calories: 3, basePrice: 25),
        Ingredient(id: "veg3", name: "Basil", image: "Basil", category: .vegetable, calories: 2, basePrice: 15),
        Ingredient(id: "veg4", name: "Black Olives", image: "Black Olives", category: .vegetable, calories: 25, basePrice: 20),
        Ingredient(id: "veg5", name: "Broccoli Roasted", image: "Broccoli Roasted", category: .vegetable, calories: 30, basePrice: 25),
        Ingredient(id: "veg6", name: "Cilantro",image: "Cilantro", category: .vegetable, calories: 8, basePrice: 15),
        Ingredient(id: "veg7", name: "Corn Roasted",image: "Corn Roasted", category: .vegetable, calories: 35, basePrice: 25),
        Ingredient(id: "veg8", name: "Crushed Red Pepper Flakes",image: "Crushed Red Pepper Flakes", category: .vegetable, calories: 5, isSpicy: true, basePrice: 10),
        Ingredient(id: "veg9", name: "Garlic Chopped",image: "Garlic Chopped", category: .vegetable, calories: 5, basePrice: 15),
        Ingredient(id: "veg10", name: "Garlic Roasted",image: "Garlic Roasted", category: .vegetable, calories: 8, basePrice: 20),
        Ingredient(id: "veg11", name: "Green Bell Peppers",image: "Green Bell Peppers", category: .vegetable, calories: 20, basePrice: 20),
        Ingredient(id: "veg12", name: "Jalapeños",image: "Jalapeños", category: .vegetable, calories: 8, isSpicy: true, basePrice: 25),
        Ingredient(id: "veg13", name: "Mama Lil's Sweet Hot Peppas",image: "Mama Lil's Sweet Hot Peppas", category: .vegetable, calories: 25, isSpicy: true, basePrice: 35),
        Ingredient(id: "veg14", name: "Mushroom",image: "Mushroom", category: .vegetable, calories: 15, basePrice: 20),
        Ingredient(id: "veg15", name: "Oregano",image: "Oregano", category: .vegetable, calories: 2, basePrice: 10),
        Ingredient(id: "veg16", name: "Pineapple",image: "Pineapple", category: .vegetable, calories: 45, basePrice: 30),
        Ingredient(id: "veg17", name: "Red Onion",image: "Red Onion", category: .vegetable, calories: 18, basePrice: 20),
        Ingredient(id: "veg18", name: "Red Pepper Roasted",image: "Red Pepper Roasted", category: .vegetable, calories: 25, basePrice: 25),
        Ingredient(id: "veg19", name: "Sea Salt & Pepper",image: "Sea Salt & Pepper", category: .vegetable, calories: 0, basePrice: 5),
        Ingredient(id: "veg20", name: "Spinach",image: "Spinach", category: .vegetable, calories: 7, basePrice: 20),
        Ingredient(id: "veg21", name: "Tomato Diced",image: "Tomato Diced", category: .vegetable, calories: 15, basePrice: 20),
        Ingredient(id: "veg22", name: "Tomato Sliced",image: "Tomato Sliced", category: .vegetable, calories: 18, basePrice: 25),
        
        // Finishing Sauces
        Ingredient(id: "finish1", name: "Balsamic Fig Glaze",image: "Balsamic Fig Glaze",category: .finishingSauce, calories: 25, basePrice: 15),
        Ingredient(id: "finish2", name: "BBQ Sauce",image: "BBQ", category: .finishingSauce, calories: 35, basePrice: 10),
        Ingredient(id: "finish3", name: "Frank's RedHot Buffalo Sauce",image: "red", category: .finishingSauce, calories: 15, isSpicy: true, basePrice: 10),
        Ingredient(id: "finish4", name: "Mike's Hot Honey",image: "Mike's Hot Honey", category: .finishingSauce, calories: 30, basePrice: 15),
        Ingredient(id: "finish5", name: "Olive Oil", image: "oil", category: .finishingSauce, calories: 40, basePrice: 10),
        Ingredient(id: "finish6", name: "Pesto",image: "Pesto", category: .finishingSauce, calories: 50, basePrice: 15),
        Ingredient(id: "finish7", name: "Ranch", image: "Ranch",category: .finishingSauce, calories: 45, basePrice: 10),
        Ingredient(id: "finish8", name: "Sriracha", image: "Sriracha", category: .finishingSauce, calories: 20, isSpicy: true, basePrice: 10),
        Ingredient(id: "finish9", name: "Tomato Sauce Dollops", image: "Tomato Sauce Dollops", category: .finishingSauce, calories: 20, basePrice: 10)
    ]
    
    // MARK: - Restaurants
    static let restaurants: [Restaurant] = [
        Restaurant(
            id: "mod_001",
            name: "MOD Pizza - Downtown Austin",
            address: "1801 E 51st St",
            city: "Austin",
            state: "TX",
            postalCode: "78723",
            phoneNumber: "+1 512 555 0001",
            location: Restaurant.RestaurantLocation(latitude: 30.3068, longitude: -97.7162),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 0.8,
            estimatedDeliveryTime: 35,
            estimatedPickupTime: 15,
            rating: 4.6,
            totalRatings: 342
        ),
        Restaurant(
            id: "mod_002",
            name: "MOD Pizza - North Austin",
            address: "11521 N Ranch Rd 620",
            city: "Austin",
            state: "TX",
            postalCode: "78726",
            phoneNumber: "+1 512 555 0002",
            location: Restaurant.RestaurantLocation(latitude: 30.4532, longitude: -97.8345),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 2.1,
            estimatedDeliveryTime: 40,
            estimatedPickupTime: 20,
            rating: 4.4,
            totalRatings: 287
        ),
        Restaurant(
            id: "mod_003",
            name: "MOD Pizza - South Austin",
            address: "9600 S I-35 Frontage Rd",
            city: "Austin",
            state: "TX",
            postalCode: "78748",
            phoneNumber: "+1 512 555 0003",
            location: Restaurant.RestaurantLocation(latitude: 30.1587, longitude: -97.7932),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 3.4,
            estimatedDeliveryTime: 45,
            estimatedPickupTime: 18,
            rating: 4.5,
            totalRatings: 198
        ),
        Restaurant(
            id: "mod_004",
            name: "MOD Pizza - Seattle Downtown",
            address: "1201 3rd Ave",
            city: "Seattle",
            state: "WA",
            postalCode: "98101",
            phoneNumber: "+1 206 555 0004",
            location: Restaurant.RestaurantLocation(latitude: 47.6072, longitude: -122.3356),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 1.2,
            estimatedDeliveryTime: 35,
            estimatedPickupTime: 17,
            rating: 4.7,
            totalRatings: 456
        ),
        Restaurant(
            id: "mod_005",
            name: "MOD Pizza - Bellevue",
            address: "1100 Bellevue Way NE",
            city: "Bellevue",
            state: "WA",
            postalCode: "98004",
            phoneNumber: "+1 425 555 0005",
            location: Restaurant.RestaurantLocation(latitude: 47.6101, longitude: -122.2015),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 2.8,
            estimatedDeliveryTime: 40,
            estimatedPickupTime: 20,
            rating: 4.5,
            totalRatings: 312
        ),
        Restaurant(
            id: "mod_006",
            name: "MOD Pizza - Los Angeles",
            address: "8500 Sunset Blvd",
            city: "Los Angeles",
            state: "CA",
            postalCode: "90069",
            phoneNumber: "+1 323 555 0006",
            location: Restaurant.RestaurantLocation(latitude: 34.0977, longitude: -118.3722),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 1.7,
            estimatedDeliveryTime: 35,
            estimatedPickupTime: 22,
            rating: 4.4,
            totalRatings: 523
        ),
        Restaurant(
            id: "mod_007",
            name: "MOD Pizza - San Diego",
            address: "1234 Harbor Dr",
            city: "San Diego",
            state: "CA",
            postalCode: "92101",
            phoneNumber: "+1 619 555 0007",
            location: Restaurant.RestaurantLocation(latitude: 32.7157, longitude: -117.1611),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 2.4,
            estimatedDeliveryTime: 40,
            estimatedPickupTime: 19,
            rating: 4.6,
            totalRatings: 389
        ),
        Restaurant(
            id: "mod_008",
            name: "MOD Pizza - Chicago",
            address: "500 N Michigan Ave",
            city: "Chicago",
            state: "IL",
            postalCode: "60611",
            phoneNumber: "+1 312 555 0008",
            location: Restaurant.RestaurantLocation(latitude: 41.8919, longitude: -87.6247),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 1.5,
            estimatedDeliveryTime: 35,
            estimatedPickupTime: 20,
            rating: 4.5,
            totalRatings: 467
        ),
        Restaurant(
            id: "mod_009",
            name: "MOD Pizza - Denver",
            address: "1500 16th St",
            city: "Denver",
            state: "CO",
            postalCode: "80202",
            phoneNumber: "+1 303 555 0009",
            location: Restaurant.RestaurantLocation(latitude: 39.7487, longitude: -104.9965),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 2.0,
            estimatedDeliveryTime: 40,
            estimatedPickupTime: 18,
            rating: 4.6,
            totalRatings: 298
        ),
        Restaurant(
            id: "mod_010",
            name: "MOD Pizza - Phoenix",
            address: "200 E Camelback Rd",
            city: "Phoenix",
            state: "AZ",
            postalCode: "85012",
            phoneNumber: "+1 602 555 0010",
            location: Restaurant.RestaurantLocation(latitude: 33.5095, longitude: -112.0712),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 2.7,
            estimatedDeliveryTime: 45,
            estimatedPickupTime: 21,
            rating: 4.4,
            totalRatings: 245
        ),
        Restaurant(
            id: "mod_011",
            name: "MOD Pizza - Dallas",
            address: "2500 McKinney Ave",
            city: "Dallas",
            state: "TX",
            postalCode: "75201",
            phoneNumber: "+1 214 555 0011",
            location: Restaurant.RestaurantLocation(latitude: 32.7952, longitude: -96.8028),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 1.9,
            estimatedDeliveryTime: 35,
            estimatedPickupTime: 16,
            rating: 4.7,
            totalRatings: 398
        ),
        Restaurant(
            id: "mod_012",
            name: "MOD Pizza - Houston",
            address: "1800 Main St",
            city: "Houston",
            state: "TX",
            postalCode: "77002",
            phoneNumber: "+1 713 555 0012",
            location: Restaurant.RestaurantLocation(latitude: 29.7520, longitude: -95.3655),
            isOpen: true,
            openingHours: [
                Restaurant.OpeningHours(day: .monday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .tuesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .wednesday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .thursday, openTime: "10:30", closeTime: "22:00", isClosed: false),
                Restaurant.OpeningHours(day: .friday, openTime: "10:30", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .saturday, openTime: "11:00", closeTime: "23:00", isClosed: false),
                Restaurant.OpeningHours(day: .sunday, openTime: "11:00", closeTime: "21:00", isClosed: false)
            ],
            availableOrderTypes: [.delivery, .takeaway, .dineIn],
            distance: 2.3,
            estimatedDeliveryTime: 40,
            estimatedPickupTime: 19,
            rating: 4.5,
            totalRatings: 321
        )
    ]
    
    // MARK: - Offer Banners
    static let offerBanners: [OfferBanner] = [
        OfferBanner(
            id: "banner1",
            title: "DOUBLE THE POINTS",
            subtitle: "This Weekend",
            description: "Earn 2X Loyalty Points on your favorite MOD Pizza.",
            backgroundColor: "#8B0000",
            textColor: "#FFFFFF",
            callToAction: "ORDER NOW"
        )
    ]
    
    // MARK: - Latest Offers
    static let latestOffers: [LatestOffer] = [
        LatestOffer(
            id: "offer1",
            title: "FLAT 50% OFF",
            description: "Artisanal Pizzas Feast",
            discountPercentage: "50%",
            promoCode: "MODFEAST",
            endDate: Date().addingTimeInterval(7200),
            minOrderValue: 299,
            applicableCategories: ["Pizza"]
        ),
        LatestOffer(
            id: "offer2",
            title: "BOGO TU",
            description: "Buy 1 Get 1 Free on Tuesdays",
            discountPercentage: "BOGO",
            promoCode: "BOGOTU",
            endDate: Date().addingTimeInterval(86400 * 7),
            minOrderValue: 399,
            applicableCategories: ["Pizza"]
        )
    ]
    
    // MARK: - Loyalty Data
    static let loyaltySummary = LoyaltySummary(
        availablePoints: 1240,
        pendingPoints: 84,
        pointsToNextReward: 260,
        currentTier: LoyaltyTier(
            id: "tier1",
            name: "Silver",
            description: "Enjoy exclusive benefits",
            requiredPoints: 1000,
            benefits: ["2X Points on weekends", "Birthday reward", "Priority support"]
        ),
        nextTier: LoyaltyTier(
            id: "tier2",
            name: "Gold",
            description: "Premium membership benefits",
            requiredPoints: 2500,
            benefits: ["3X Points on weekends", "Free birthday meal", "Exclusive offers", "Priority seating"]
        ),
        memberSince: Date().addingTimeInterval(-86400 * 365),
        totalPointsEarned: 2500,
        totalPointsRedeemed: 1256
    )
    
    static let rewards: [Reward] = [
        Reward(
            id: "reward1",
            name: "Free Drink",
            description: "Any soft drink on the house",
            pointsRequired: 100,
            category: .drink
        ),
        Reward(
            id: "reward2",
            name: "₹10 Off",
            description: "Get ₹10 off your next order",
            pointsRequired: 250,
            category: .discount
        ),
        Reward(
            id: "reward3",
            name: "Free Meal",
            description: "Complimentary pizza and drink",
            pointsRequired: 500,
            category: .food
        ),
        Reward(
            id: "reward4",
            name: "Garlic Bread",
            description: "Free garlic bread with any order",
            pointsRequired: 150,
            category: .food
        )
    ]
    
    static let campaigns: [Campaign] = [
        Campaign(
            id: "campaign1",
            title: "2X Points Weekend",
            description: "Earn double points on all orders this weekend",
            type: .doublePoints,
            startDate: Date().addingTimeInterval(-86400),
            endDate: Date().addingTimeInterval(86400 * 2),
            eligibility: Campaign.CampaignEligibility(isForNewCustomersOnly: false),
            callToAction: "Order Now"
        ),
        Campaign(
            id: "campaign2",
            title: "Birthday Reward",
            description: "Get a special treat on your birthday",
            type: .birthdayBonus,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 365),
            eligibility: Campaign.CampaignEligibility(isForNewCustomersOnly: false),
            callToAction: "Verify Birthday"
        ),
        Campaign(
            id: "campaign3",
            title: "New Member Bonus",
            description: "Get 100 bonus points when you sign up",
            type: .newMember,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            eligibility: Campaign.CampaignEligibility(isForNewCustomersOnly: true),
            callToAction: "Sign Up"
        )
    ]
    
    static let loyaltyTransactions: [LoyaltyTransaction] = [
        LoyaltyTransaction(
            id: "trans1",
            type: .earned,
            points: 84,
            description: "Order #MOD10284",
            orderId: "MOD10284",
            status: .pending,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        LoyaltyTransaction(
            id: "trans2",
            type: .earned,
            points: 120,
            description: "Order #MOD10201",
            orderId: "MOD10201",
            status: .completed,
            createdAt: Date().addingTimeInterval(-86400 * 7),
            processedAt: Date().addingTimeInterval(-86400 * 5)
        ),
        LoyaltyTransaction(
            id: "trans3",
            type: .redeemed,
            points: -250,
            description: "₹10 Off Reward",
            rewardId: "reward2",
            status: .completed,
            createdAt: Date().addingTimeInterval(-86400 * 14),
            processedAt: Date().addingTimeInterval(-86400 * 14)
        )
    ]
}
