package com.sunyeh.m100

import com.sunyeh.m100.data.*
import com.sunyeh.m100.viewmodel.*
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.core.module.Module
import org.koin.dsl.module

enum class MainStatus {
    Connecting,
    ConnectFailed,
    LoginFailed,
    Unlogined,
    General,
    Dealer,
    Developer,
    DisConnect,
    QuickEnable
}

enum class SettingStatus {
    Loading,
    Timeout,
    Finish,
    Disconnect
}

interface NotifyDelegate {
    fun disconnect()
    fun recvData(dataBytes: ByteArray)
}

val mainModule: Module = module {
    viewModel { MainViewModel(MainRepository()) }
    viewModel { StatusViewModel(StatusRepository()) }
    viewModel { MaintainViewModel(MaintainRepository()) }
    viewModel { MonitorViewModel(MonitorRepository()) }
    viewModel { RemoteControlViewModel(RemoteControlRepository()) }
    viewModel { ProductConfigViewModel(ProductConfigRepository()) }
    viewModel { MaintainConfigViewModel(MaintainConfigRepository()) }
    viewModel { SystemConfigViewModel(SystemConfigRepository()) }
    viewModel { UngentConfigViewModel(UngentConfigRepository()) }
    viewModel { SwitchConfigViewModel(SwitchConfigRepository()) }
    viewModel { ControlModelConfigViewModel(ControlModeConfigRepository()) }
    viewModel { OutputConfigViewModel(OutputConfigRepository()) }
}