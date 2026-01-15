import 'package:flutter/material.dart';
import '../backend/models/service_record.dart';

class JobStatusStepper extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStepTap;

  const JobStatusStepper({
    super.key,
    required this.currentStatus,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define the sequence of steps
    final steps = [
      ServiceRecord.statusInspectionPending,
      ServiceRecord.statusApprovalPending,
      ServiceRecord.statusInProgress,
      ServiceRecord.statusReady,
      ServiceRecord.statusDelivered,
    ];

    // Determine current index
    int currentIndex = steps.indexOf(currentStatus);
    if (currentIndex == -1) currentIndex = 0; // Default to first if unknown

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
           SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(steps.length * 2 - 1, (index) {
                // Determine if this is a separator or a step
                if (index.isOdd) {
                  // Separator Logic
                   int prevStepIndex = (index - 1) ~/ 2;
                   bool isCompleted = prevStepIndex < currentIndex;
                   
                  return Container(
                    width: 30, 
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  );
                } else {
                  // Step Logic
                  final stepIndex = index ~/ 2;
                  final isActive = stepIndex == currentIndex;
                  final isCompleted = stepIndex < currentIndex;
                  final statusName = _getShortName(steps[stepIndex]);

                  return GestureDetector(
                    onTap: () => onStepTap(steps[stepIndex]),
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCompleted || isActive ? Colors.green : Colors.grey[200],
                            shape: BoxShape.circle,
                            boxShadow: isActive ? [
                              BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
                            ] : [],
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : Text(
                                    (stepIndex + 1).toString(),
                                    style: TextStyle(
                                      color: isActive ? Colors.white : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusName,
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive ? Colors.green[800] : Colors.grey[600],
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _getShortName(String status) {
    switch (status) {
      case ServiceRecord.statusInspectionPending: return 'Insp';
      case ServiceRecord.statusApprovalPending: return 'Approve';
      case ServiceRecord.statusInProgress: return 'Work';
      case ServiceRecord.statusReady: return 'Ready';
      case ServiceRecord.statusDelivered: return 'Done';
      default: return '?';
    }
  }
}
