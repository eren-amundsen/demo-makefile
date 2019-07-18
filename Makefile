# Makefile构建nodejs项目

# 检查语法
# 编译模板
# 转码
# 合并
# 压缩
# 测试
# 删除

# 写入两行通用配置
PATH := node_modules/.bin:${PATH}
SHELL := /bin/bash

# PATH和SHELL都是BASH的变量，它们被重新赋值

# PATH变量重新赋值为，优先在 node_modules/.bin 目录寻找命令。
# 这是因为（当前项目的）node模块，会在 node_modules/.bin 目录设置一个符号链接。
# PATH变量指向这个目录以后，调用各种命令就不用写路径了。
# 比如，调用JSHint，就不用写 ~/node_modules/.bin/jshint ，只写 jshint 就行了。

# SHELL变量指定构建环境使用BASH。


# 1.检查语法
js_files = $(shell find ./lib -name '*.js')

lint: $(js_files)
	jshint $?



# 2.编译模板
.PHONY: build/templates.js
build/templates.js: templates/*.handlebars
	mkdir -p $(dir $@)
	handlebars templates/*.handlebars > $@

template: build/templates.js



# 3.Coffee脚本转码(编译为js文件)
source_files := $(wildcard lib/*.coffee)
build_files := $(source_files:lib/%.coffee=build/%.js)

build/%.js: lib/%.coffee
	coffee -co $(dir $@) $<

coffee: $(build_files)



# 4.合并文件
JS_FILES := $(wildcard build/*.js)
OUTPUT := build/bundle.js

concat: $(JS_FILES)
	cat $^ > $(OUTPUT)



# 5.压缩js脚本
app_bundle := build/app.js

all_js := $(wildcard build/*.js)
$(app_bundle): $(build_files) $(all_js)
	uglifyjs -cmo $@ $^

min: $(app_bundle)

# 还有另一种写法
# UGLIFY ?= uglify

# $(app_bundle): $(build_files) $(all_js)
# 	$(UGLIFY) -cmo $@ $^

# 上面代码将压缩工具uglify放在变量UGLIFY。注意，变量的赋值符是 ?= ，表示这个变量可以被命令行参数覆盖
# 调用时这样写：
# make UGLIFY=node_modules/.bin/jsmin min



# 6.删除临时文件
clean:
	rm -fr build



# 7.测试
# 假定测试工具是mocha，所有测试用例放在test目录下
test: $(app_bundle) $(test_js)
	mocha



# 8.多任务执行
# 将build指定为执行模板编译、文件合并、脚本压缩、删除临时文件四个任务
build: template coffee concat min clean

# 如果这行规则在Makefile的最前面，执行时可以省略目标名
# $ make

# 通常情况下，make一次执行一个任务。如果任务都是独立的，互相没有依赖关系，可以用参数 -j 指定同时执行多个任务
# $ make -j build



# 9.声明伪文件
# 为了防止目标名与现有文件冲突，显式声明哪些目标是伪文件
.PHONY: lint template coffee concat min test clean build



# 10.Makefile文件实例

# 第一个实例示范：
# PROJECT = "My Fancy Node.js project"

# all: install test server

# test: ;@echo "Testing ${PROJECT}....."; \
#     export NODE_PATH=.; \
#     ./node_modules/mocha/bin/mocha;

# install: ;@echo "Installing ${PROJECT}....."; \
#     npm install

# update: ;@echo "Updating ${PROJECT}....."; \
#     git pull --rebase; \
#     npm install

# clean : ;
#     rm -rf node_modules

# .PHONY: test server install clean update


# 第二个实例示范：
# all: build-js build-css

# build-js: 
#   browserify -t brfs src/app.js > site/app.js

# build-css:
#   stylus src/style.styl > site/style.css

# .PHONY: build-js build-css
