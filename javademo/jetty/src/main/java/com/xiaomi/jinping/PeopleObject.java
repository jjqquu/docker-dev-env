package com.xiaomi.jinping;

import java.io.Serializable;

/**
 * Created by qujinping on 16/1/5.
 */
public class PeopleObject {

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    String name;
    int age;

}