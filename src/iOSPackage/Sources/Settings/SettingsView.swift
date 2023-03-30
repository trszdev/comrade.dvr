import SwiftUI
import ComposableArchitecture
import Util
import Assets
import LocalizedUtils
import ComposableArchitectureExtensions
import CommonUI
import Permissions

public struct SettingsView: View {
  @Environment(\.language) var language
  @Environment(\.appearance) var appearance

  public init(store: Store<SettingsState, SettingsAction>) {
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    Form {
      cameraSectionView

      interfaceSectionView

//      if let notificationsEnabled = viewStore.localState.notificationsEnabled {
//        pushSectionView(notificationsEnabled: notificationsEnabled)
//      }

      proSectionView

      infoSectionView
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
      viewStore.send(.updatePermissionStatus)
    }
    .onAppear {
      viewStore.send(.updatePermissionStatus)
    }
  }

  private var proLabelView: some View {
    Text(language.string(.pro))
      .foregroundColor(appearance.color(.proColor))
      .overlay(
        HStack {
          if viewStore.isPremium {
            Image(systemName: "checkmark")
              .resizable()
              .foregroundColor(appearance.color(.proCheckmarkColor))
              .scaledToFit()
              .frame(width: 10)
          }
          Spacer()
        }
        .offset(x: -15)
      )
  }

  private var proSectionView: some View {
    Section(header: proLabelView) {
      if !viewStore.isPremium {
        Button {
          viewStore.send(.upgradeToPro)
        } label: {
          HStack {
            Text(verbatim: "Upgrade to pro, 7 day free trial")
              .foregroundColor(appearance.color(.textColorDefault))

            Spacer()

            Image(systemName: "chevron.right.2")
              .foregroundColor(appearance.color(.proColor))
          }
        }
      }

      Toggle(isOn: viewStore.binding(\.$settings.autoStart)) {
        Text(language.string(.autostart))
          .foregroundColor(
            viewStore.isPremium ? appearance.color(.textColorDefault) : appearance.color(.textColorDisabled)
          )
      }
      .disabled(!viewStore.isPremium)
    }
  }

  private var infoSectionView: some View {
    Section(header: Text(language.string(.contactUs))) {
      Button {
        viewStore.send(.contactUs)
      } label: {
        Text(verbatim: language.appEmail)
      }
      .contextMenu {
        Button {
          viewStore.send(.contactUsCopy)
        } label: {
          Text(language.string(.copy))
          Image(systemName: "doc.on.doc.fill")
        }
      }

      DestructiveButton {
        showClearAllAssets = true
      } label: {
        HStack {
          Spacer()

          Text(language.string(.clearAssets))
            .foregroundColor(appearance.color(.textColorDestructive))

          Spacer()
        }
      }
    }
    .alert(isPresented: $showClearAllAssets) {
      Alert(
        title: Text(language.string(.warning)),
        message: Text(language.string(.clearAllAssetsAsk)),
        primaryButton: .destructive(Text(language.string(.clearAllAssetsConfirm))) {
          viewStore.send(.clearAllRecordings)
        },
        secondaryButton: .cancel(Text(language.string(.cancel)))
      )
    }
  }

  private var cameraSectionView: some View {
    Section {
      Picker(
        selection: viewStore.binding(\.$settings.totalFileSize),
        label: Text(language.string(.assetsLimit))
      ) {
        ForEach(assetLimits, id: \.self) {
          Text(language.assetSize($0)).tag($0)
        }
      }

      Picker(
        selection: viewStore.binding(\.$settings.maxFileLength),
        label: Text(language.string(.assetLength))
      ) {
        ForEach(maxFileLengths, id: \.self) {
          Text(language.duration($0)).tag($0)
        }
      }
    }
  }

  private func pushSectionView(notificationsEnabled: Bool) -> some View {
    Section(header: Text(language.pushSectionHeader(notificationsEnabled))) {
      let binding = viewStore.binding(\.$settings.recordingNotifications)

      if !notificationsEnabled {
        Button {
          viewStore.send(.openNotificationSettings)
        } label: {
          Text(language.string(.permissionsDenied))
        }
      }

      Toggle(isOn: binding) {
        Text(language.string(.record))
          .foregroundColor(
            notificationsEnabled ? appearance.color(.textColorDefault) : appearance.color(.textColorDisabled)
          )
      }
      .disabled(!notificationsEnabled)
    }
  }

  private var interfaceSectionView: some View {
    Section {
      Picker(
        selection: viewStore.binding(\.$settings.language),
        label: Text(language.string(.language))
      ) {
        ForEach(languages, id: \.self) {
          Text(language.languageName($0)).tag($0)
        }
      }

      Picker(
        selection: viewStore.binding(\.$settings.appearance),
        label: Text(language.string(.theme))
      ) {
        ForEach(appearances, id: \.self) {
          Text(language.appearanceName($0)).tag($0)
        }
      }
    }
  }

  @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>
  @State private var showClearAllAssets = false
}

private let languages: [Language?] = Language.allCases + [nil]
private let appearances: [Appearance?] = Appearance.allCases + [nil]
private let maxFileLengths: [TimeInterval] = [
  .minutes(1),
  .minutes(2),
  .minutes(3),
  .minutes(5),
  .minutes(10),
]

private let assetLimits: [FileSize?] = [
  .gigabytes(1),
  .gigabytes(5),
  .gigabytes(10),
  .gigabytes(20),
  .gigabytes(40),
  nil,
]

struct SettingsViewPreviews: PreviewProvider {
  static var previews: some View {
    SettingsView(store: .init(initialState: .init(), reducer: settingsReducer, environment: .init()))
  }
}
