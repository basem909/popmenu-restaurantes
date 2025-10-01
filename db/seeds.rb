# frozen_string_literal: true

# Sample data to exercise the JSON API in development
# The records are created idempotently so you can run `rails db:seed`
# multiple times without producing duplicates.

restaurants_data = [
  {
    name: 'Sunrise Diner',
    menus: [
      {
        name: 'Breakfast Classics',
        description: 'Morning staples served until noon.',
        active: true,
        starts_at: Time.zone.parse('2024-01-01 06:00'),
        ends_at:   Time.zone.parse('2024-01-01 12:00')
      },
      {
        name: 'Weekend Brunch',
        description: 'Limited menu available on Saturdays and Sundays.',
        active: false,
        starts_at: Time.zone.parse('2024-01-01 10:00'),
        ends_at:   Time.zone.parse('2024-01-01 14:00')
      },
      {
        name: 'Seasonal Specials',
        description: 'Chef rotating dishes for the current season.',
        active: true,
        starts_at: Time.zone.parse('2024-03-01 07:00'),
        ends_at:   Time.zone.parse('2024-03-01 15:00')
      }
    ],
    menu_items: [
      {
        name: 'Buttermilk Pancakes',
        description: 'Fluffy stack with maple syrup and whipped butter.',
        price: 6.75,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Breakfast Classics', price_on_menu: 7.50, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Avocado Toast',
        description: 'Toasted sourdough with smashed avocado, feta, and chili flakes.',
        price: 8.50,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Breakfast Classics', price_on_menu: 9.50, currency_on_menu: 'USD' },
          { name: 'Seasonal Specials', price_on_menu: 9.75, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Citrus Salad',
        description: 'Grapefruit, orange, mint, and honey yogurt.',
        price: 9.00,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Weekend Brunch', price_on_menu: 10.00, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Cold Brew Coffee',
        description: 'House-brewed, served over ice.',
        price: 4.00,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Breakfast Classics', price_on_menu: 4.50, currency_on_menu: 'USD' },
          { name: 'Weekend Brunch',   price_on_menu: 4.75, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Seasonal Soup',
        description: 'Chef selection that changes weekly.',
        price: 5.00,
        currency: 'USD',
        active: false,
        menus: []
      },
      {
        name: 'Veggie Omelette',
        description: 'Three-egg omelette with peppers, spinach, and goat cheese.',
        price: 7.25,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Breakfast Classics', price_on_menu: 7.75, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Overnight Oats',
        description: 'Steel-cut oats soaked with almond milk, chia, and berries.',
        price: 6.00,
        currency: 'USD',
        active: false,
        menus: [
          { name: 'Seasonal Specials', price_on_menu: 6.25, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Maple Bacon Biscuit',
        description: 'House-made biscuit with maple glazed bacon and fried egg.',
        price: 6.50,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Seasonal Specials', price_on_menu: 7.25, currency_on_menu: 'USD' }
        ]
      }
    ]
  },
  {
    name: 'Moonlight Grill',
    menus: [
      {
        name: 'Lunch Plates',
        description: 'Midday favorites and lighter fare.',
        active: true,
        starts_at: Time.zone.parse('2024-01-01 11:00'),
        ends_at:   Time.zone.parse('2024-01-01 16:00')
      },
      {
        name: 'Late Night Bites',
        description: 'Shareable plates after 9 PM.',
        active: true,
        starts_at: Time.zone.parse('2024-01-01 21:00'),
        ends_at:   Time.zone.parse('2024-01-01 23:30')
      },
      {
        name: "Chef's Tasting",
        description: 'Rotating tasting menu with seasonal specials.',
        active: false,
        starts_at: Time.zone.parse('2024-01-01 17:00'),
        ends_at:   Time.zone.parse('2024-01-01 21:00')
      },
      {
        name: 'Happy Hour',
        description: 'Discounted snacks and drinks from 5-7 PM.',
        active: true,
        starts_at: Time.zone.parse('2024-01-01 17:00'),
        ends_at:   Time.zone.parse('2024-01-01 19:00')
      }
    ],
    menu_items: [
      {
        name: 'Grilled Salmon',
        description: 'Atlantic salmon with lemon herb butter and asparagus.',
        price: 17.50,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Lunch Plates', price_on_menu: 18.00, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Steak Frites',
        description: 'Grilled sirloin served with rosemary fries and garlic aioli.',
        price: 20.00,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Lunch Plates', price_on_menu: 21.00, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Truffle Fries',
        description: 'Hand-cut fries tossed in truffle oil and parmesan.',
        price: 7.50,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Lunch Plates',     price_on_menu: 8.50, currency_on_menu: 'USD' },
          { name: 'Late Night Bites', price_on_menu: 9.00, currency_on_menu: 'USD' },
          { name: 'Happy Hour',       price_on_menu: 7.00, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Spicy Nachos',
        description: 'Tortilla chips with poblano queso, pickled jalapeños, and salsa roja.',
        price: 10.00,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Late Night Bites', price_on_menu: 11.50, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Mini Cheesecake',
        description: 'Individual vanilla bean cheesecakes with berry compote.',
        price: 6.00,
        currency: 'USD',
        active: true,
        menus: [
          { name: "Chef's Tasting", price_on_menu: 6.50, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Seasonal Mocktail',
        description: 'Zero-proof cocktail featuring rotating seasonal produce.',
        price: 5.50,
        currency: 'USD',
        active: false,
        menus: []
      },
      {
        name: 'Crispy Brussels',
        description: 'Brussels sprouts with honey-chili glaze and toasted almonds.',
        price: 8.75,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Happy Hour', price_on_menu: 8.00, currency_on_menu: 'USD' },
          { name: 'Late Night Bites', price_on_menu: 9.25, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Chocolate Lava Cake',
        description: 'Warm chocolate cake with molten center and vanilla ice cream.',
        price: 7.25,
        currency: 'USD',
        active: false,
        menus: [
          { name: "Chef's Tasting", price_on_menu: 7.75, currency_on_menu: 'USD' }
        ]
      }
    ]
  },
  {
    name: 'Harbor Cafe',
    menus: [
      {
        name: 'All Day Menu',
        description: 'Comfort food available throughout the day.',
        active: true,
        starts_at: Time.zone.parse('2024-01-01 08:00'),
        ends_at:   Time.zone.parse('2024-01-01 21:00')
      },
      {
        name: 'Sunset Specials',
        description: 'Limited seafood-forward menu at sunset.',
        active: false,
        starts_at: Time.zone.parse('2024-01-01 17:00'),
        ends_at:   Time.zone.parse('2024-01-01 20:00')
      },
      {
        name: 'Weekend Treats',
        description: 'Desserts and small bites featured on weekends.',
        active: true,
        starts_at: Time.zone.parse('2024-01-01 12:00'),
        ends_at:   Time.zone.parse('2024-01-01 22:00')
      }
    ],
    menu_items: [
      {
        name: 'Lobster Roll',
        description: 'Butter-toasted brioche roll packed with chilled lobster.',
        price: 18.00,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'All Day Menu', price_on_menu: 18.50, currency_on_menu: 'USD' },
          { name: 'Sunset Specials', price_on_menu: 19.00, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Clam Chowder',
        description: 'Creamy chowder with clams, potatoes, and smokey bacon.',
        price: 7.00,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'All Day Menu', price_on_menu: 7.25, currency_on_menu: 'USD' },
          { name: 'Sunset Specials', price_on_menu: 7.50, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Fisherman Stew',
        description: 'Tomato-saffron broth with mussels, shrimp, and cod.',
        price: 16.50,
        currency: 'USD',
        active: false,
        menus: [
          { name: 'Sunset Specials', price_on_menu: 17.00, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Key Lime Tart',
        description: 'Tart lime custard with graham crust and whipped cream.',
        price: 5.50,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'Weekend Treats', price_on_menu: 6.00, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Roasted Beet Salad',
        description: 'Mixed greens with roasted beets, goat cheese, and walnuts.',
        price: 9.25,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'All Day Menu', price_on_menu: 9.75, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Blueberry Scone',
        description: 'Fresh-baked scone with lemon glaze.',
        price: 3.75,
        currency: 'USD',
        active: false,
        menus: [
          { name: 'Weekend Treats', price_on_menu: 4.00, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Iced Matcha Latte',
        description: 'Ceremonial grade matcha with oat milk over ice.',
        price: 4.25,
        currency: 'USD',
        active: true,
        menus: [
          { name: 'All Day Menu', price_on_menu: 4.50, currency_on_menu: 'USD' }
        ]
      },
      {
        name: 'Seasonal Flatbread',
        description: 'Wood-fired flatbread topped with grilled veggies and feta.',
        price: 11.00,
        currency: 'USD',
        active: false,
        menus: [
          { name: 'Weekend Treats', price_on_menu: 11.50, currency_on_menu: 'USD' }
        ]
      }
    ]
  }
]

users_data = [
  {
    email: 'demo@popmenu.test',
    password: 'Password1!',
    page_auth: []
  },
  {
    email: 'importer@popmenu.test',
    password: 'Password1!',
    page_auth: ['import']
  },
  {
    email: 'manager@popmenu.test',
    password: 'Password1!',
    page_auth: ['reports', 'import']
  }
]

puts '== Seeding restaurants, menus, and menu items =='

ActiveRecord::Base.transaction do
  restaurants_data.each do |rest_data|
    restaurant = Restaurant.find_or_initialize_by(name: rest_data[:name])
    restaurant.save! unless restaurant.persisted?

    menus_by_name = {}

    rest_data.fetch(:menus, []).each do |menu_data|
      menu = restaurant.menus.find_or_initialize_by(name: menu_data[:name])
      menu.assign_attributes(menu_data.slice(:description, :active, :starts_at, :ends_at))
      menu.save!
      menus_by_name[menu.name] = menu
    end

    rest_data.fetch(:menu_items, []).each do |item_data|
      menu_links = Array(item_data[:menus])

      menu_item = restaurant.menu_items.find_or_initialize_by(name: item_data[:name])
      menu_item.assign_attributes(item_data.slice(:description, :price, :currency, :active))
      menu_item.save!

      menu_links.each do |link|
        menu = menus_by_name[link[:name]] || restaurant.menus.find_by(name: link[:name])
        unless menu
          warn "  ⚠️  Menu #{link[:name].inspect} not found for #{restaurant.name}, skipping link"
          next
        end

        menu_itemization = MenuItemization.find_or_initialize_by(menu:, menu_item: menu_item)
        menu_itemization.assign_attributes(
          price_on_menu:   link[:price_on_menu],
          currency_on_menu: link[:currency_on_menu]
        )
        menu_itemization.save!
      end
    end

    active_count   = restaurant.menu_items.active.count
    inactive_count = restaurant.menu_items.where(active: false).count
    puts "  ✓ #{restaurant.name}: #{restaurant.menus.count} menus, #{restaurant.menu_items.count} items (#{active_count} active / #{inactive_count} inactive)"
  end

  puts '\n== Seeding demo users =='

  users_data.each do |attrs|
    user = User.find_or_initialize_by(email: attrs[:email])
    user.password = attrs[:password]
    user.password_confirmation = attrs[:password]
    user.page_auth = attrs[:page_auth]
    user.save!
    puts "  ✓ #{user.email} (page_auth: #{user.page_auth.join(', ').presence || 'none'})"
  end
end

puts '\nSeed data loaded. You can now explore the API with the demo restaurants and users.'
