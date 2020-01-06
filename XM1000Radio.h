#ifndef XM1000RADIO_H
#define XM1000RADIO_H

typedef nx_struct radio_sense_msg {
  nx_uint32_t light;
} XM1000Msg;

enum{
  AM_XM1000MSG = 7
};

#endif
