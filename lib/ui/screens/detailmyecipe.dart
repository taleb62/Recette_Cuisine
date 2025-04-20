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
  List<Map<String, dynamic>> _reviews = [];
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    fetchReviews();
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    try {
      final response = await supabase
          .from('favorite')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('recipe_id', widget.recipe['id'])
          .single();

      setState(() {
        _isFavorite = response != null;
      });
    } catch (e) {
      setState(() {
        _isFavorite = false;
      });
    }
  }

  Future<void> toggleFavorite() async {
    try {
      if (_isFavorite) {
        await supabase
            .from('favorite')
            .delete()
            .eq('user_id', supabase.auth.currentUser!.id)
            .eq('recipe_id', widget.recipe['id']);
        Get.snackbar('Removed', 'Recipe removed from favorites');
      } else {
        await supabase.from('favorite').insert({
          'user_id': supabase.auth.currentUser!.id,
          'recipe_id': widget.recipe['id'],
        });
        Get.snackbar('Added', 'Recipe added to favorites');
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> fetchReviews() async {
    try {
      final response = await supabase
          .from('review')
          .select('review, rate, user_id, user(profile_image, name)')
          .eq('recipe_id', widget.recipe['id']);

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
      Navigator.pop(context);
      _reviewController.clear();
      setState(() {
        _selectedRating = 0;
      });
      fetchReviews();
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Write a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Your Review',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          color: index < _selectedRating ? Colors.amber : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitReview,
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildIngredientList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        widget.recipe['ingredient'].length,
        (index) {
          final ingredient = widget.recipe['ingredient'][index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ingredient['name']} - ${ingredient['amount']} ${ingredient['unit']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildReviewList() {
    if (_reviews.isEmpty) {
      return const Center(
        child: Text(
          'No reviews yet. Be the first to review!',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        final user = review['user'];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: user['profile_image'] != null
                          ? NetworkImage(user['profile_image'])
                          : const AssetImage('assets/default_user.png') as ImageProvider,
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      user['name'] ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      Icons.star,
                      size: 20,
                      color: starIndex < review['rate'] ? Colors.amber : Colors.grey,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  review['review'] ?? '',
                  style: const TextStyle(fontSize: 14),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['name']),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.recipe['id'],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.recipe['image'] ?? '',
                    height: size.height * 0.3,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.recipe['name'],
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Serves: ${widget.recipe['people']} | Time: ${widget.recipe['time']} mins',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildIngredientList(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: openReviewDialog,
                icon: const Icon(Icons.rate_review),
                label: const Text('Write a Review'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reviews:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildReviewList(),
            ],
          ),
        ),
      ),
    );
  }
}
