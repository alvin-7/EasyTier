use std::ffi::{c_char, CStr, CString};
use std::ptr;

// iOS 特定的错误处理
#[repr(C)]
pub struct IosError {
    pub code: i32,
    pub message: *const c_char,
}

impl IosError {
    pub fn new(code: i32, message: &str) -> Self {
        let c_string = CString::new(message).unwrap();
        Self {
            code,
            message: c_string.into_raw(),
        }
    }
}

#[no_mangle]
pub extern "C" fn free_ios_error(error: *mut IosError) {
    if !error.is_null() {
        unsafe {
            let error = &mut *error;
            if !error.message.is_null() {
                let _ = CString::from_raw(error.message as *mut c_char);
            }
        }
    }
}

// iOS 网络实例管理
#[repr(C)]
pub struct IosNetworkInstance {
    pub instance_id: *const c_char,
    pub status: i32, // 0: stopped, 1: running, 2: error
}

#[no_mangle]
pub extern "C" fn ios_create_network_instance(
    config_json: *const c_char,
) -> *mut IosNetworkInstance {
    let config_str = unsafe {
        assert!(!config_json.is_null());
        CStr::from_ptr(config_json).to_string_lossy().into_owned()
    };

    // 调用现有的 run_network_instance 函数
    let result = crate::run_network_instance(config_json);
    
    if result == 0 {
        // 成功创建实例
        let instance_id = CString::new("instance_1").unwrap();
        let instance = Box::new(IosNetworkInstance {
            instance_id: instance_id.into_raw(),
            status: 1,
        });
        Box::into_raw(instance)
    } else {
        ptr::null_mut()
    }
}

#[no_mangle]
pub extern "C" fn ios_start_network_instance(
    instance: *mut IosNetworkInstance,
) -> *mut IosError {
    if instance.is_null() {
        return Box::into_raw(Box::new(IosError::new(-1, "Invalid instance")));
    }

    unsafe {
        (*instance).status = 1;
    }
    
    ptr::null_mut()
}

#[no_mangle]
pub extern "C" fn ios_stop_network_instance(
    instance: *mut IosNetworkInstance,
) -> *mut IosError {
    if instance.is_null() {
        return Box::into_raw(Box::new(IosError::new(-1, "Invalid instance")));
    }

    unsafe {
        (*instance).status = 0;
    }
    
    ptr::null_mut()
}

#[no_mangle]
pub extern "C" fn ios_get_network_status(
    instance: *const IosNetworkInstance,
) -> i32 {
    if instance.is_null() {
        return -1;
    }
    
    unsafe {
        (*instance).status
    }
}

#[no_mangle]
pub extern "C" fn ios_free_network_instance(instance: *mut IosNetworkInstance) {
    if !instance.is_null() {
        unsafe {
            let instance = &mut *instance;
            if !instance.instance_id.is_null() {
                let _ = CString::from_raw(instance.instance_id as *mut c_char);
            }
        }
        let _ = Box::from_raw(instance);
    }
}

// iOS 配置验证
#[no_mangle]
pub extern "C" fn ios_validate_config(config_json: *const c_char) -> *mut IosError {
    let result = crate::parse_config(config_json);
    
    if result == 0 {
        ptr::null_mut()
    } else {
        Box::into_raw(Box::new(IosError::new(result, "Configuration validation failed")))
    }
}

// iOS 网络信息获取
#[no_mangle]
pub extern "C" fn ios_get_network_info(
    instance: *const IosNetworkInstance,
    info_json: *mut *const c_char,
) -> *mut IosError {
    if instance.is_null() {
        return Box::into_raw(Box::new(IosError::new(-1, "Invalid instance")));
    }

    // 这里可以调用现有的 collect_network_infos 函数
    // 简化实现，返回基本状态信息
    let status = unsafe { (*instance).status };
    let status_str = match status {
        0 => "stopped",
        1 => "running",
        2 => "error",
        _ => "unknown",
    };
    
    let info = format!("{{\"status\": \"{}\"}}", status_str);
    let c_string = CString::new(info).unwrap();
    unsafe {
        *info_json = c_string.into_raw();
    }
    
    ptr::null_mut()
} 