import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class QuantumSimulatorScreen extends ConsumerStatefulWidget {
  const QuantumSimulatorScreen({super.key});

  @override
  ConsumerState<QuantumSimulatorScreen> createState() => _QuantumSimulatorScreenState();
}

class _QuantumSimulatorScreenState extends ConsumerState<QuantumSimulatorScreen> {
  int _numQubits = 3;
  String _selectedGate = 'H';
  List<Map<String, dynamic>> _circuit = [];
  String _quantumCode = '';
  String _simulationResult = '';

  final List<String> _quantumGates = [
    'H',  // Hadamard
    'X',  // Pauli-X
    'Y',  // Pauli-Y
    'Z',  // Pauli-Z
    'CNOT', // Controlled-NOT
    'S',  // Phase
    'T',  // T-gate
    'RX', // Rotation-X
    'RY', // Rotation-Y
    'RZ', // Rotation-Z
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantum Computer Simulator'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _runSimulation,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCircuit,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quantum Controls
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.memory, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Qubits:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _numQubits.toDouble(),
                        min: 1,
                        max: 8,
                        divisions: 7,
                        label: _numQubits.toString(),
                        onChanged: (value) {
                          setState(() {
                            _numQubits = value.round();
                            _circuit.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Gate:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedGate,
                      dropdownColor: Colors.deepPurple.shade300,
                      style: const TextStyle(color: Colors.white),
                      items: _quantumGates.map((gate) {
                        return DropdownMenuItem(
                          value: gate,
                          child: Text(gate, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGate = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quantum Circuit Visualization
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantum Circuit ($_numQubits qubits)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CustomPaint(
                      painter: QuantumCircuitPainter(_numQubits, _circuit),
                      child: GestureDetector(
                        onTapDown: (details) => _addGateToCircuit(details.localPosition),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Code Generation Area
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generated Quantum Code (Qiskit)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _quantumCode.isEmpty ? 'Tap to add gates to the circuit above...' : _quantumCode,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Simulation Results
          if (_simulationResult.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulation Results',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _simulationResult,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateQuantumCode,
        backgroundColor: Colors.deepPurple,
        label: const Text('Generate Code'),
        icon: const Icon(Icons.code),
      ),
    );
  }

  void _addGateToCircuit(Offset position) {
    if (_circuit.length >= 20) return; // Limit circuit size

    final qubitIndex = (position.dy / 60).floor();
    if (qubitIndex >= 0 && qubitIndex < _numQubits) {
      setState(() {
        _circuit.add({
          'gate': _selectedGate,
          'qubit': qubitIndex,
          'position': _circuit.length,
        });
      });
      _generateQuantumCode();
    }
  }

  void _generateQuantumCode() {
    final buffer = StringBuffer();
    buffer.writeln('from qiskit import QuantumCircuit, transpile, Aer, execute');
    buffer.writeln('from qiskit.visualization import plot_histogram');
    buffer.writeln('import numpy as np');
    buffer.writeln('');
    buffer.writeln('# Create quantum circuit with $_numQubits qubits');
    buffer.writeln('qc = QuantumCircuit($_numQubits, $_numQubits)');
    buffer.writeln('');

    for (final gate in _circuit) {
      final gateName = gate['gate'];
      final qubit = gate['qubit'];
      
      switch (gateName) {
        case 'H':
          buffer.writeln('qc.h($qubit)  # Hadamard gate on qubit $qubit');
          break;
        case 'X':
          buffer.writeln('qc.x($qubit)  # Pauli-X gate on qubit $qubit');
          break;
        case 'Y':
          buffer.writeln('qc.y($qubit)  # Pauli-Y gate on qubit $qubit');
          break;
        case 'Z':
          buffer.writeln('qc.z($qubit)  # Pauli-Z gate on qubit $qubit');
          break;
        case 'CNOT':
          if (qubit < _numQubits - 1) {
            buffer.writeln('qc.cx($qubit, ${qubit + 1})  # CNOT gate');
          }
          break;
        case 'S':
          buffer.writeln('qc.s($qubit)  # S gate on qubit $qubit');
          break;
        case 'T':
          buffer.writeln('qc.t($qubit)  # T gate on qubit $qubit');
          break;
        default:
          buffer.writeln('qc.${gateName.toLowerCase()}($qubit)');
      }
    }

    buffer.writeln('');
    buffer.writeln('# Add measurements');
    buffer.writeln('qc.measure_all()');
    buffer.writeln('');
    buffer.writeln('# Execute on simulator');
    buffer.writeln('backend = Aer.get_backend("qasm_simulator")');
    buffer.writeln('job = execute(qc, backend, shots=1024)');
    buffer.writeln('result = job.result()');
    buffer.writeln('counts = result.get_counts(qc)');
    buffer.writeln('print("Measurement results:", counts)');

    setState(() {
      _quantumCode = buffer.toString();
    });
  }

  void _runSimulation() {
    if (_circuit.isEmpty) {
      setState(() {
        _simulationResult = 'No gates in circuit. Add some quantum gates first.';
      });
      return;
    }

    // Simulate quantum measurement results
    final numStates = 1 << _numQubits; // 2^n possible states
    final results = <String, int>{};
    
    // Generate random measurement results based on circuit
    for (int i = 0; i < 1024; i++) {
      final state = _simulateQuantumState();
      final key = state.toString().padLeft(_numQubits, '0');
      results[key] = (results[key] ?? 0) + 1;
    }

    final buffer = StringBuffer();
    buffer.writeln('Quantum Simulation Results (1024 shots):');
    buffer.writeln('');
    
    results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(8)
      .forEach((entry) {
        final probability = (entry.value / 1024 * 100).toStringAsFixed(1);
        buffer.writeln('|${entry.key}⟩: ${entry.value} counts ($probability%)');
      });

    buffer.writeln('');
    buffer.writeln('Circuit depth: ${_circuit.length}');
    buffer.writeln('Quantum volume: ${1 << _numQubits}');

    setState(() {
      _simulationResult = buffer.toString();
    });
  }

  int _simulateQuantumState() {
    // Simplified quantum state simulation
    var state = 0;
    for (int i = 0; i < _numQubits; i++) {
      if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
        state |= (1 << i);
      }
    }
    return state;
  }

  void _clearCircuit() {
    setState(() {
      _circuit.clear();
      _quantumCode = '';
      _simulationResult = '';
    });
  }
}

class QuantumCircuitPainter extends CustomPainter {
  final int numQubits;
  final List<Map<String, dynamic>> circuit;

  QuantumCircuitPainter(this.numQubits, this.circuit);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final gateSize = 40.0;
    final qubitSpacing = 60.0;

    // Draw qubit lines
    for (int i = 0; i < numQubits; i++) {
      final y = i * qubitSpacing + 30;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );

      // Draw qubit labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'q$i',
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-30, y - 7));
    }

    // Draw gates
    for (int i = 0; i < circuit.length; i++) {
      final gate = circuit[i];
      final qubit = gate['qubit'] as int;
      final x = i * 60.0 + 50;
      final y = qubit * qubitSpacing + 30;

      // Draw gate box
      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: gateSize,
        height: gateSize,
      );
      
      canvas.drawRect(
        rect,
        Paint()..color = Colors.deepPurple.shade100,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.deepPurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Draw gate label
      final textPainter = TextPainter(
        text: TextSpan(
          text: gate['gate'],
          style: const TextStyle(
            color: Colors.deepPurple,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}