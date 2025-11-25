import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/inventory_bloc.dart';
import '../../domain/entities/inventory_item.dart';

class AddInventoryItemScreen extends StatefulWidget {
  final InventoryItem? item;

  const AddInventoryItemScreen({super.key, this.item});

  @override
  State<AddInventoryItemScreen> createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockCostController = TextEditingController();
  final _intendedProfitController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final item = widget.item!;
    _nameController.text = item.name;
    _stockCostController.text = item.stockCost.toString();
    _intendedProfitController.text = item.intendedProfit.toString();
    _quantityController.text = item.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    
    return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Item' : 'Add Item'),
          backgroundColor: const Color(0xFF7430EB),
        ),
        body: BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is InventoryOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF7B4EFF),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.fixed,
                ),
              );
              Navigator.pop(context);
            } else if (state is InventoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Item Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter item name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Stock Cost and Intended Profit
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockCostController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stock Cost *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money),
                            suffixText: 'RWF',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _intendedProfitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Intended Profit *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.trending_up),
                            suffixText: 'RWF',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Selling Price Preview
                  if (_stockCostController.text.isNotEmpty && _intendedProfitController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Selling Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${_calculateSellingPrice().toStringAsFixed(0)} RWF',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Save Button
                  BlocBuilder<InventoryBloc, InventoryState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is InventoryLoading ? null : _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7430EB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: state is InventoryLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEditing ? 'Update Item' : 'Add Item',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  double _calculateSellingPrice() {
    final stockCost = double.tryParse(_stockCostController.text) ?? 0;
    final intendedProfit = double.tryParse(_intendedProfitController.text) ?? 0;
    return stockCost + intendedProfit;
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final item = InventoryItem(
      id: widget.item?.id,
      name: _nameController.text.trim(),
      stockCost: double.parse(_stockCostController.text),
      intendedProfit: double.parse(_intendedProfitController.text),
      quantity: int.parse(_quantityController.text),
      createdAt: widget.item?.createdAt ?? DateTime.now(),
    );

    if (widget.item != null) {
      context.read<InventoryBloc>().add(UpdateInventoryItem(item));
    } else {
      context.read<InventoryBloc>().add(AddInventoryItem(item));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockCostController.dispose();
    _intendedProfitController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}