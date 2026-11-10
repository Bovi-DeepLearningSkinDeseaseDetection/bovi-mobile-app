import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/connection_status_chip.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/origin_image.dart';
import '../viewmodels/capture_view_model.dart';
import '../widgets/capture/camera_error_view.dart';
import '../widgets/capture/camera_viewfinder.dart';
import '../widgets/capture/capture_controls.dart';
import '../widgets/help_frame.dart';
import '../widgets/low_resolution_dialog.dart';
import 'image_preview_page.dart';

/// Capture screen (HU01, HU02, HU03). The camera state lives in
/// [CaptureViewModel]; this page draws it and leads to the preview.
class CapturePage extends StatelessWidget {
  /// Opens the history. Without it, the history action shows a notice.
  final VoidCallback? onHistory;

  const CapturePage({super.key, this.onHistory});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaptureViewModel()..start(),
      child: _CaptureView(onHistory: onHistory),
    );
  }
}

class _CaptureView extends StatefulWidget {
  final VoidCallback? onHistory;

  const _CaptureView({required this.onHistory});

  @override
  State<_CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends State<_CaptureView> {
  CaptureViewModel get _model => context.read<CaptureViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHelpFirstTime());
  }

  // HU03, scenario 2: framing help the first time the camera opens.
  Future<void> _showHelpFirstTime() async {
    final model = _model;
    if (!await model.shouldShowHelp() || !mounted) return;
    await showFramingHelp(context);
    await model.markHelpAsSeen();
  }

  Future<void> _capture() => _model.whileBusy(() async {
    try {
      final image = await _model.takePhoto();
      if (mounted) await _openPreview(image);
    } on CaptureFailure catch (failure) {
      _showMessage(failure.message);
    }
  });

  // HU02: a low-resolution image or "Elegir otra" picks again.
  Future<void> _selectFromGallery() => _model.whileBusy(() async {
    try {
      while (mounted) {
        final image = await _model.pickFromGallery();
        if (image == null || !mounted) return; // The user canceled.
        if (image.meetsMinimumResolution) {
          if (!await _openPreview(image)) return;
          continue;
        }
        final choice = await showLowResolutionDialog(context);
        if (choice != LowResolutionChoice.chooseAnother) return;
      }
    } on CaptureFailure catch (failure) {
      _showMessage(failure.message);
    }
  });

  /// Shows the preview and returns whether the user wants another gallery
  /// image. Camera photos are temporary, so they are deleted afterwards.
  Future<bool> _openPreview(CapturedImage image) async {
    final model = _model;
    final decision = await Navigator.of(context).push<PreviewDecision>(
      MaterialPageRoute(builder: (_) => ImagePreviewPage(image: image)),
    );
    await model.discard(image);
    return image.origin == ImageOrigin.gallery &&
        decision == PreviewDecision.retake;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CaptureViewModel>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Escanear'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Cómo tomar la foto',
            onPressed: () => showFramingHelp(context),
          ),
          StreamBuilder<bool>(
            stream: model.connection,
            initialData: false,
            builder: (context, snapshot) =>
                ConnectionStatusChip(isOnline: snapshot.data ?? false),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // The viewfinder is a dark card with rounded bottom corners that
          // rests on the white panel of the controls.
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              child: ColoredBox(color: Colors.black, child: _viewfinder(model)),
            ),
          ),
          CaptureControls(
            isBusy: model.isBusy,
            onGallery: _selectFromGallery,
            onCapture: _capture,
            onHistory:
                widget.onHistory ??
                () => _showMessage(
                  'El historial estará disponible próximamente.',
                ),
          ),
        ],
      ),
    );
  }

  Widget _viewfinder(CaptureViewModel model) {
    final error = model.error;
    if (error != null) {
      return CameraErrorView(
        message: error,
        showSettings: model.permissionDenied,
        onRetry: model.initializeCamera,
      );
    }
    final controller = model.controller;
    if (model.isLoading || controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.lightGreen),
      );
    }
    return CameraViewfinder(
      controller: controller,
      isSteady: model.isSteady,
      focusPosition: model.focusPosition,
      focusTaps: model.focusTaps,
      showFlash: model.showFlash,
      onTap: model.focusAt,
    );
  }
}
