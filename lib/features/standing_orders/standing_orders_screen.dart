
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/standing_order.dart';
import '../../models/doc_content.dart';

class StandingOrdersScreen extends StatefulWidget {
  const StandingOrdersScreen({super.key});

  @override
  State<StandingOrdersScreen> createState() => _StandingOrdersScreenState();
}

class _StandingOrdersScreenState extends State<StandingOrdersScreen> {
  // --- State ---
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  bool documentMode = false;
  bool showFavoritesOnly = false;
  String searchQuery = '';
  List<StandingOrder> standingOrders = [];
  List<StandingOrder> filteredOrders = [];
  StandingOrder? selectedOrder;
  List<DocContent> docChunks = [];
  List<DocContent> filteredChunks = [];
  DocContent? selectedChunk;
  String? uploadedFilename;
  String aiExplanation = '';
  bool aiLoading = false;
  bool showFullDocument = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
      isError = false;
      errorMessage = '';
    });
    try {
      final client = Supabase.instance.client;
      
      // Try to load uploaded document from Supabase (id = "standing_orders")
      try {
        final docResponse = await client
            .from('standing_orders_documents')
            .select()
            .eq('id', 'standing_orders')
            .maybeSingle();

        if (docResponse != null) {
          // Document found, parse chunks
          documentMode = true;
          uploadedFilename = docResponse['filename'] as String?;
          final chunksData = docResponse['chunks'] as List<dynamic>? ?? [];
          docChunks = chunksData
              .map((chunk) => DocContent.fromMap(chunk as Map<String, dynamic>))
              .toList();
          filteredChunks = List.from(docChunks);
          standingOrders = [];
          filteredOrders = [];
        } else {
          // No document, load standing orders
          final response = await client
              .from('standing_orders')
              .select()
              .order('code', ascending: true);

          final list = response as List<dynamic>;
          standingOrders = list
              .map((row) => StandingOrder.fromMap(row as Map<String, dynamic>))
              .toList();
          filteredOrders = List.from(standingOrders);
          documentMode = false;
          docChunks = [];
          filteredChunks = [];
          uploadedFilename = null;
        }
      } catch (e) {
        // If document table doesn't exist, just load standing orders
        final response = await client
            .from('standing_orders')
            .select()
            .order('code', ascending: true);

        final list = response as List<dynamic>;
        standingOrders = list
            .map((row) => StandingOrder.fromMap(row as Map<String, dynamic>))
            .toList();
        filteredOrders = List.from(standingOrders);
        documentMode = false;
        docChunks = [];
        filteredChunks = [];
        uploadedFilename = null;
      }
      selectedOrder = null;
      selectedChunk = null;
      showFullDocument = false;
    } catch (e) {
      isError = true;
      errorMessage = 'Failed to load data: $e';
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // --- Search ---
    // void _onSearchChanged(String value) {
    //   setState(() {
    //     _searchQuery = value;
    //   });
    //   if (documentMode) {
    //     _filterDocChunks();
    //   } else {
    //     _filterStandingOrders();
    //   }
    // }

  // Removed unused _filterStandingOrders and _filterDocChunks methods.

  // --- Favorites ---
  Future<void> _toggleFavorite(StandingOrder order) async {
    try {
      final newFavorite = !order.isFavorite;
      final client = Supabase.instance.client;
      
      // Update in Supabase
      await client
          .from('standing_orders')
          .update({'is_favorite': newFavorite})
          .eq('id', order.id);
      
      // Update locally
      setState(() {
        final updated = order.copyWith(isFavorite: newFavorite);
        final idx = standingOrders.indexWhere((o) => o.id == order.id);
        if (idx != -1) standingOrders[idx] = updated;
        if (selectedOrder?.id == order.id) selectedOrder = updated;
        _filterStandingOrders();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    }
  }

  void _filterStandingOrders() {
    filteredOrders = standingOrders
        .where((order) => !showFavoritesOnly || order.isFavorite)
        .where((order) => searchQuery.isEmpty ||
            order.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            order.code.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // --- Mode switching ---
    // void _enterDocumentMode(String filename, List<DocContent> chunks) {
    //   setState(() {
    //     documentMode = true;
    //     uploadedFilename = filename;
    //     docChunks = chunks;
    //     filteredChunks = chunks;
    //     selectedChunk = null;
    //     showFullDocument = false;
    //   });
    // }

  void _exitDocumentMode() {
    setState(() {
      documentMode = false;
      uploadedFilename = null;
      docChunks = [];
      filteredChunks = [];
      selectedChunk = null;
      showFullDocument = false;
    });
  }

  // --- File upload ---
  Future<void> _uploadDocument() async {
    try {
      // TODO: Implement file picker and parsing for PDF/DOCX
      // For now, placeholder implementation
      // In production, you would:
      // 1. Use file_picker to select PDF/DOCX
      // 2. Parse the document into chunks
      // 3. Upload chunks to Supabase
      // 4. Call _enterDocumentMode
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File picker coming soon')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e')),
      );
    }
  }

  void _filterDocChunks() {
    filteredChunks = docChunks
        .where((chunk) => searchQuery.isEmpty ||
            chunk.text.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _enterDocumentMode(String filename, List<DocContent> chunks) {
    setState(() {
      documentMode = true;
      uploadedFilename = filename;
      docChunks = chunks;
      filteredChunks = chunks;
      selectedChunk = null;
      showFullDocument = false;
    });
  }

  // --- AI Explanation ---
  // Note: geminiService not yet wired into this screen constructor
  // TODO: Add geminiService parameter to StandingOrdersScreen constructor
  // Future<void> _explainText(String label, String text) async {
  //   setState(() {
  //     aiLoading = true;
  //     aiExplanation = '';
  //   });
  //   try {
  //     // Uncomment when geminiService is available:
  //     // final explanation = await widget.geminiService.generateText(text);
  //     // setState(() {
  //     //   aiExplanation = explanation;
  //     // });
  //   } catch (e) {
  //     setState(() {
  //       aiExplanation = 'Error: $e';
  //     });
  //   } finally {
  //     setState(() {
  //       aiLoading = false;
  //     });
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standing Orders'),
        actions: [
          if (!documentMode)
            TextButton.icon(
              onPressed: _uploadDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          if (documentMode)
            TextButton.icon(
              onPressed: _exitDocumentMode,
              icon: const Icon(Icons.close),
              label: const Text('Close Reader'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(32),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Governance • Rules • Legal Framework',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text(errorMessage))
              : isSmallScreen
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    // TODO: Implement mobile layout switching between list and details
    // Show list when selectedOrder/selectedChunk is null
    // Show details when selectedOrder/selectedChunk is selected
    // Add back button to return to list
    if (documentMode) {
      if (selectedChunk == null) {
        return _buildLeftPanel();
      } else {
        return _buildRightPanel();
      }
    } else {
      if (selectedOrder == null) {
        return _buildLeftPanel();
      } else {
        return _buildRightPanel();
      }
    }
  }

  Widget _buildDesktopLayout() {
    // TODO: Implement desktop layout with left and right panels
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildLeftPanel(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _buildRightPanel(),
        ),
      ],
    );
  }

  Widget _buildLeftPanel() {
    // TODO: Implement search, favorites toggle, and list
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    if (documentMode) {
                      _filterDocChunks();
                    } else {
                      _filterStandingOrders();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              if (!documentMode)
                Row(
                  children: [
                    Checkbox(
                      value: showFavoritesOnly,
                      onChanged: (value) {
                        setState(() {
                          showFavoritesOnly = value ?? false;
                          _filterStandingOrders();
                        });
                      },
                    ),
                    const Text('Show Favorites Only'),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: documentMode
              ? ListView.builder(
                  itemCount: filteredChunks.length,
                  itemBuilder: (_, i) {
                    final chunk = filteredChunks[i];
                    return ListTile(
                      title: Text(
                        chunk.text.length > 50
                            ? chunk.text.substring(0, 50) + '...'
                            : chunk.text,
                      ),
                      selected: selectedChunk?.id == chunk.id,
                      onTap: () {
                        setState(() => selectedChunk = chunk);
                      },
                    );
                  },
                )
              : ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (_, i) {
                    final order = filteredOrders[i];
                    return Card(
                      child: ListTile(
                        title: Text(order.title),
                        subtitle: Text(order.code),
                        trailing: IconButton(
                          icon: Icon(
                            order.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: order.isFavorite ? Colors.red : null,
                          ),
                          onPressed: () => _toggleFavorite(order),
                        ),
                        selected: selectedOrder?.id == order.id,
                        onTap: () {
                          setState(() => selectedOrder = order);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    // TODO: Implement details, tags, AI explanation, document context
    if (documentMode && selectedChunk == null) {
      return const Center(child: Text('Select a chunk to view details'));
    }
    if (!documentMode && selectedOrder == null) {
      return const Center(child: Text('Select a standing order to view details'));
    }

    if (documentMode && selectedChunk != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Page: ${selectedChunk!.page ?? 'N/A'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Text(selectedChunk!.text, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            if (aiLoading)
              const Center(child: CircularProgressIndicator())
            else if (aiExplanation.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Explanation',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(aiExplanation),
                ],
              ),
          ],
        ),
      );
    } else if (!documentMode && selectedOrder != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(selectedOrder!.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Code: ${selectedOrder!.code}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            if (selectedOrder!.tags.isNotEmpty) ...[
              const Text('Tags:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: selectedOrder!.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            const Divider(),
            const SizedBox(height: 12),
            const Text('Content:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(selectedOrder!.content),
            const SizedBox(height: 24),
            if (aiLoading)
              const Center(child: CircularProgressIndicator())
            else if (aiExplanation.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Explanation',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(aiExplanation),
                ],
              ),
          ],
        ),
      );
    }
    return const Center(child: Text('No selection'));
  }
}
