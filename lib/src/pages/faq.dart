import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pembs_produce/src/helpers/constants/colors.dart';
import 'package:pembs_produce/src/pages/donation.dart';
import 'package:pembs_produce/src/pages/shop_map.dart';
import 'package:resend/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  bool _isLoading = false;

  final List<FAQ> _faqs = getFAQs();

  final FocusNode _focusNodeTitle = FocusNode();
  final FocusNode _focusNodeDesc = FocusNode();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  void dispose() {
    _focusNodeTitle.dispose();
    _focusNodeDesc.dispose();

    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Widget _renderFAQs() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          if (_faqs[index].isExpanded) {
            _faqs[index].isExpanded = false;
          } else {
            _faqs[index].isExpanded = true;
          }
        });
      },
      children: _faqs.map<ExpansionPanel>((FAQ faq) {
        return ExpansionPanel(
          canTapOnHeader: true,
          backgroundColor: AppColors.primaryBackground.withOpacity(0.1),
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                faq.title,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.w700),
              ),
            );
          },
          body: ListTile(
            title: Text(faq.body),
          ),
          isExpanded: faq.isExpanded,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ShopMapPage(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (_, a, __, c) => FadeTransition(
                  opacity: a,
                  child: c,
                ),
              ));
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text("FAQ/Help Page"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              Container(
                child: _renderFAQs(),
              ),
            ],
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.bottomCenter,
      persistentFooterButtons: [
        ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(Color(Colors.red.value))),
            onPressed: () async {
              await _reportIssueDialog();
            },
            icon: const Icon(Icons.payment),
            label: const Text("Report an issue")),
        ElevatedButton.icon(
            onPressed: () async {
              await _processDonation();
            },
            icon: const Icon(Icons.payment),
            label: const Text("Make a donation")),
      ],
    );
  }

  void _closeDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _isLoading = false;
    Navigator.of(context).pop();
  }

  Future<bool> isFormValid() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _onSubmit() async {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1));
    try {
      // Validate the form
      bool formValid = await isFormValid();
      if (!formValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "The form is invalid, please make sure all fields are complete."),
            elevation: 2.5,
            duration: Duration(seconds: 10),
          ));
          _isLoading = false;
          return;
        }
      }
      await supabase.from('problem_reports').insert({
        "title": _titleController.value.text,
        "description": _descriptionController.value.text,
      });

      await resend.sendEmail(
          from: "farmshops@resend.dev",
          to: ["pembsproduce@gmail.com"],
          subject: "Problem reported",
          text:
              'Name: ${_titleController.value.text}\nDescription: ${_descriptionController.value.text}');
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } on ResendException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() => _isLoading = false);

    _closeDialog();
    if (mounted) {
      await showDialog<void>(
          useSafeArea: true,
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return const Center(
              child: AlertDialog(
                content: SizedBox(
                  height: 250,
                  child: Center(
                    child: Text(
                      "Thank you for your feedback.\n\nYour issue has been noted.",
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          });
    }
  }

  _reportIssueDialog() async {
    await showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 2.0,
            scrollable: true,
            title: const Center(child: Text('Report an issue')),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      focusNode: _focusNodeTitle,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'What\'s the issue?',
                      ),
                      onTap: () => _focusNodeTitle.requestFocus(),
                      onTapOutside: (event) => _focusNodeTitle.unfocus(),
                    ),
                    TextFormField(
                      focusNode: _focusNodeDesc,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'A brief summary...',
                      ),
                      onTap: () => _focusNodeDesc.requestFocus(),
                      onTapOutside: (event) => _focusNodeDesc.unfocus(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    _isLoading ? null : await _onSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(8.0),
                      minimumSize: const Size(172, 32),
                      backgroundColor: Colors.red),
                      
                  icon: _isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.feedback, size: 12.0),
                  label: const Text('Report issue'),
                ),
              ),
              
            ],
          );
        });
  }

  _processDonation() async {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const DonationPage(),
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, a, __, c) => FadeTransition(
        opacity: a,
        child: c,
      ),
    ));
  }
}

class FAQ {
  FAQ(this.title, this.body, [this.isExpanded = false]);
  String title;
  String body;
  bool isExpanded;
}

List<FAQ> getFAQs() {
  return [
    FAQ('Add to PembsProduce',
        'On the map, tap the "+" icon and a dialog will appear to let you add a place.\nPlease note: All the fields must be filled out and an image must be added for the location to be sent for review.'),
    FAQ('Report an issue',
        'Tap the red "Report an issue" button at the bottom of this screen and you will be given a pop-up to report your issue.'),
    FAQ('Support PembsProduce',
        'Tap the orange "Make a donation" button at the bottom of this screen and you will be given an option to make a one-time or monthly donation.\n\nCURRENTLY DISABLED'),
  ];
}
