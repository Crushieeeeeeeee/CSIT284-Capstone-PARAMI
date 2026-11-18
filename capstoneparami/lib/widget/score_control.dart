import 'package:flutter/material.dart';

class ScoreControl extends StatelessWidget {
  final String name;
  final int value;
  final ValueChanged<int> onChanged;

  const ScoreControl({
    super.key,
    required this.name,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(name, textAlign: TextAlign.center, maxLines: 2),
            const SizedBox(height: 8),
            Text('$value', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                IconButton.filledTonal(
                  onPressed: value > 0 ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove),
                ),
                IconButton.filled(
                  onPressed: () => onChanged(value + 1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                for (final n in [2, 3])
                  OutlinedButton(
                    onPressed: () => onChanged(value + n),
                    child: Text('+$n'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}