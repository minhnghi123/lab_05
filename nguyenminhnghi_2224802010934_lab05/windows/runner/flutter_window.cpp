#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controllers_ = std::make_unique<flutter::FlutterViewcontrollers>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controllers was successful.
  if (!flutter_controllers_->engine() || !flutter_controllers_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controllers_->engine());
  SetChildContent(flutter_controllers_->view()->GetNativeWindow());

  flutter_controllers_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controllers_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controllers_) {
    flutter_controllers_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controllers_) {
    std::optional<LRESULT> result =
        flutter_controllers_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controllers_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
