package com.example.mybt

import com.example.mybt.Data.*
import com.example.mybt.ViewModel.*
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

interface NotifyDelegate {
    fun disconnect()
    fun recvData(dataBytes: ByteArray)
}

//Factory: 如同声明一个普通对象.
//Single: 单例模式.无论在类中声明几次都指向同一个对象.
//viewModel:声明的是我们继承 lifecycle 的 ViewModel.
val mainModule: Module = module {
    viewModel { MainViewModel(MainRepository()) }
}