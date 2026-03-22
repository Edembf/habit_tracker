import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  
  double _age = 25; 
  String _country = 'United States';
  List<String> _countries = [];
  List<String> selectedHabits = [];
  
  final List<String> availableHabits = [
    'Wake Up Early',
    'Workout',
    'Drink Water',
    'Meditate',
    'Read a Book',
    'Practice Gratitude',
    'Sleep 8 Hours',
    'Eat Healthy',
    'Journal',
    'Walk 10,000 Steps'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    // Simulating a fetch
    List<String> subsetCountries = [
      'United States', 'Canada', 'United Kingdom', 'Australia',
      'India', 'Germany', 'France', 'Japan', 'China', 'Brazil', 'South Africa'
    ];

    setState(() {
      _countries = subsetCountries;
      _countries.sort();
      // Ensure the default country exists in the list
      if (_countries.contains('United States')) {
        _country = 'United States';
      } else {
        _country = _countries.isNotEmpty ? _countries[0] : 'United States';
      }
    });
  }

  void _register() {
    // Basic Logic Check
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all details')),
      );
      return;
    }
    
    print("Name: ${_nameController.text}");
    print("Country: $_country");
    print("Selected Habits: $selectedHabits");
    
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Account created successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Seamless gradient under AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(_nameController, 'Full Name', Icons.person),
                const SizedBox(height: 15),
                _buildInputField(_usernameController, 'Username', Icons.alternate_email),
                
                const SizedBox(height: 25),
                Text('Age: ${_age.round()}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                Slider(
                  value: _age,
                  min: 18, // Changed to 18 for a standard range
                  max: 100,
                  divisions: 82,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                  onChanged: (double value) {
                    setState(() => _age = value);
                  },
                ),
                
                const SizedBox(height: 20),
                const Text('Country', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                _buildCountryDropdown(),
                
                const SizedBox(height: 25),
                const Text('Select Your Habits',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableHabits.map((habit) {
                    final isSelected = selectedHabits.contains(habit);
                    return ChoiceChip(
                      label: Text(habit),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedHabits.add(habit);
                          } else {
                            selectedHabits.remove(habit);
                          }
                        });
                      },
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white30,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue.shade800 : const Color.fromARGB(255, 188, 11, 11),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'CREATE ACCOUNT',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.blue.shade900),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _country,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
          isExpanded: true,
          items: _countries.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: Colors.blue.shade900)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() => _country = newValue!);
          },
        ),
      ),
    );
  }
}