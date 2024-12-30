import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  DetailPage({required this.recipe});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  List<Map<String, dynamic>> _reviews = []; // Holds the list of reviews

  @override
  void initState() {
    super.initState();
    fetchReviews(); // Fetch reviews when the page is initialized
  }

  Future<void> fetchReviews() async {
    try {
      final response = await supabase
          .from('review')
          .select('review, rate, user_id') // Select required fields
          .eq('recipe_id', widget.recipe['id']); // Filter by recipe ID

      if (response != null) {
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> submitReview() async {
    if (_reviewController.text.trim().isEmpty || _selectedRating == 0) {
      Get.snackbar('Error', 'Please write a review and select a rating.');
      return;
    }

    try {
      await supabase.from('review').insert({
        'review': _reviewController.text.trim(),
        'rate': _selectedRating,
        'user_id': supabase.auth.currentUser!.id,
        'recipe_id': widget.recipe['id'],
      });
      Get.snackbar('Success', 'Review submitted successfully!');
      Navigator.pop(context); // Close the dialog
      _reviewController.clear(); // Clear the review field
      setState(() {
        _selectedRating = 0; // Reset the rating
      });
      fetchReviews(); // Refresh the reviews after submission
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void openReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Write a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Review Input Field
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Your Review',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Star Rating Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          size: 32,
                          color: index < _selectedRating ? Colors.yellow : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitReview,
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildReviewList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      Icons.star,
                      size: 20,
                      color: starIndex < review['rate'] ? Colors.yellow : Colors.grey,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  review['review'] ?? 'No review text',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['name']),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () async {
              await supabase.from('favorite').insert({
                'user_id': supabase.auth.currentUser!.id,
                'recipe_id': widget.recipe['id'],
              });
              Get.snackbar('Success', 'Recipe added to favorites');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Recipe Image
              Hero(
                tag: widget.recipe['id'],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.recipe['image'] ?? '',
                    height: isWideScreen ? size.height * 0.5 : size.height * 0.3,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Recipe Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe['name'],
                      style: TextStyle(
                        fontSize: isWideScreen ? 28 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Serves: ${widget.recipe['people']} | Time: ${widget.recipe['time']} mins',
                      style: TextStyle(
                        fontSize: isWideScreen ? 18 : 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Ingredients Section
                    Text(
                      'Ingredients:',
                      style: TextStyle(
                        fontSize: isWideScreen ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      widget.recipe['ingredient'].length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.recipe['ingredient'][index]['name']} - '
                                '${widget.recipe['ingredient'][index]['amount']} '
                                '${widget.recipe['ingredient'][index]['unit']}',
                                style: TextStyle(fontSize: isWideScreen ? 16 : 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Review Button
                    ElevatedButton.icon(
                      onPressed: openReviewDialog,
                      icon: Icon(Icons.rate_review),
                      label: Text('Write a Review'),
                    ),
                    const SizedBox(height: 24),
                    // Reviews Section
                    Text(
                      'Reviews:',
                      style: TextStyle(
                        fontSize: isWideScreen ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Review List
                    buildReviewList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
