import '../../entities/transaction.dart';

class TransactionCategories {
  TransactionCategories._();

  static const List<String> expense = [
    // Living
    'Rent',
    'Electricity',
    'Water',
    'Gas',
    'Internet',
    'Mobile Phone',
    'Home Maintenance',

    // Food
    'Groceries',
    'Restaurants',
    'Fast Food',
    'Coffee',
    'Delivery',

    // Transport
    'Fuel',
    'Public Transport',
    'Taxi / Uber',
    'Car Insurance',
    'Car Repair',
    'Parking',

    // Health
    'Doctor',
    'Medicine',
    'Health Insurance',
    'Gym',
    'Therapy',

    // Shopping
    'Clothes',
    'Shoes',
    'Electronics',
    'Accessories',
    'Online Shopping',

    // Entertainment
    'Movies',
    'Streaming Services',
    'Games',
    'Events',
    'Hobbies',

    // Education
    'Books',
    'Courses',
    'Online Learning',
    'Certifications',

    // Travel
    'Flights',
    'Hotels',
    'Airbnb',
    'Activities',
    'Travel Food',

    // Finance
    'Bank Fees',
    'Loan Payment',
    'Credit Card',
    'Taxes',

    // Other
    'Gifts',
    'Charity',
    'Donations',
    'Unexpected',
    'Other',
  ];

  static const List<String> income = [
    // Main
    'Salary',
    'Freelance',
    'Contract Work',
    'Hourly Work',

    // Side Income
    'Side Projects',
    'YouTube',
    'Blog',
    'App Sales',
    'Affiliate Income',

    // Investments
    'Stocks',
    'Crypto',
    'Dividends',
    'ETFs',
    'Trading',

    // Passive
    'Rental Income',
    'Royalties',
    'Interest',

    // Other
    'Cashback',
    'Refunds',
    'Gifts',
    'Selling Items',
    'Other',
  ];

  static List<String> forType(TransactionType type) {
    return type == TransactionType.income ? income : expense;
  }

  static String defaultFor(TransactionType type) {
    return 'Other';
  }
}
