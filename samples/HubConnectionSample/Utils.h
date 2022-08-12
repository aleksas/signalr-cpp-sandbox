
#ifndef __UTILS_H__
#define __UTILS_H__

#include <iostream>
#include <iomanip>
#include <sstream>

#define NO_SIGNALRCLIENT_EXPORTS
#include <signalrclient/signalr_value.h>

std::string hexStr(const std::vector<uint8_t>& data)
{
     std::stringstream ss;
     ss << std::hex;

     for( int i(0) ; i < data.size(); ++i )
         ss << std::setw(2) << std::setfill('0') << (int)data[i];

     return ss.str();
}

void pretty_print(signalr::value value, std::ostream& stream, const std::string& prefix="") {
    if (value.is_bool()) {
        stream << prefix << value.as_bool();
    } else if (value.is_string()) {
        stream << prefix << value.as_string();
    } else if (value.is_double()) {
        stream << prefix << value.as_double();
    } else if (value.is_null()) {
        stream << prefix << "null";
    } else if (value.is_binary()) {
        stream << prefix << hexStr(value.as_binary());
    } else if (value.is_array()) {
        std::vector<signalr::value>::iterator it;
        auto arr = value.as_array();

        for(it = arr.begin(); it != arr.end(); it++) {
            pretty_print(*it, stream, prefix + "- ");
        }
    } else if (value.is_map()) {
        auto map = value.as_map();

        std::map<std::string, signalr::value>::iterator it;
        stream << prefix << "{" << std::endl;

        auto new_prefix = prefix + "  ";

        for (it = map.begin(); it != map.end(); it++)
        {
            stream << new_prefix << it->first << ":";
            pretty_print(it->second, stream, new_prefix);
        }
        stream << prefix << "}";
    }

    stream << std::endl;  
}

#endif // __UTILS_H__
