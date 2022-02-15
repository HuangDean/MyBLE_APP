package com.example.mybt.ViewModel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.cancel

open class BaseViewModel: ViewModel() {

    var isOnPause: Boolean = false

    open fun onDestory() {
        viewModelScope.cancel()
    }
}