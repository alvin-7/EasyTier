#ifndef EASYTIER_FFI_H
#define EASYTIER_FFI_H

#ifdef __cplusplus
extern "C" {
#endif

// 错误处理结构
typedef struct {
    int code;
    const char* message;
} IosError;

// 网络实例结构
typedef struct {
    const char* instance_id;
    int status; // 0: stopped, 1: running, 2: error
} IosNetworkInstance;

// 基础函数
const char* get_error_msg(const char** out);
void free_string(const char* s);
int parse_config(const char* cfg_str);
int run_network_instance(const char* cfg_str);

// iOS 特定函数
void free_ios_error(IosError* error);
IosNetworkInstance* ios_create_network_instance(const char* config_json);
IosError* ios_start_network_instance(IosNetworkInstance* instance);
IosError* ios_stop_network_instance(IosNetworkInstance* instance);
int ios_get_network_status(const IosNetworkInstance* instance);
void ios_free_network_instance(IosNetworkInstance* instance);
IosError* ios_validate_config(const char* config_json);
IosError* ios_get_network_info(const IosNetworkInstance* instance, const char** info_json);

#ifdef __cplusplus
}
#endif

#endif // EASYTIER_FFI_H 