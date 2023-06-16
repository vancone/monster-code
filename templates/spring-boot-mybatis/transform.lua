function getModelName(model)
    local modelName = model.Name
    local ModelName = modelName:gsub('^%l',string.upper)
    return modelName, ModelName
end

function generatePom()
    files = {}
    local otherDependencies = ''
    local finalSource = source

    local redisInjected = false
    for i = 1, #(project.Deployment.Env) do
        local env = project.Deployment.Env[i]
        -- Add Redis dependency
        if #(project.Deployment.Env[1].Middleware.Redis) > 0 and redisInjected == false then
            otherDependencies = otherDependencies .. '\n\n' ..
                '        <dependency>\n' ..
                '            <groupId>org.springframework.boot</groupId>\n' ..
                '            <artifactId>spring-boot-starter-data-redis</artifactId>\n' ..
                '        </dependency>'
            redisInjected = true
        end
    end

    if plugins['vancone-passport-sdk'] == true then
        otherDependencies = otherDependencies .. '\n\n' ..
                '        <dependency>\n' ..
                '            <groupId>com.vancone</groupId>\n' ..
                '            <artifactId>vancone-passport-sdk</artifactId>\n' ..
                '            <version>0.1.1</version>\n' ..
                '        </dependency>'
    end

    finalSource = string.gsub(finalSource, '${otherDependencies}', otherDependencies)
    files['pom.xml'] = finalSource
    return files
end

function generateEntities()
    models = project.Models
    files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${modelName}', ModelName)
        local fieldCode = ''
        for k = 1, #models[i].Fields do
            fieldCode = fieldCode .. '    private String ' .. models[i].Fields[k].Name .. ';\n'
        end
        finalSource = finalSource.gsub(finalSource, '${fields}', fieldCode)
        files[ModelName .. '.java'] = finalSource
    end
    return files
end

function generateMappers()
    models = project.Models
    files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'Mapper.java'] = finalSource
    end
    return files
end

function generateMapperXmlFiles()
    models = project.Models
    files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        finalSource = string.gsub(finalSource, '${tableName}', models[i].TablePrefix .. modelName)

        -- Fill in result map fields
        local resultMapFieldsCode = ''
        for k = 1, #models[i].Fields do
            local field = models[i].Fields[k]
            if (field.Primary)
            then
                resultMapFieldsCode = resultMapFieldsCode .. '        <id column="' .. field.Name .. '" property="' .. field.Name .. '" jdbcType="VARCHAR"/>\n'
            else
                resultMapFieldsCode = resultMapFieldsCode .. '        <result column="' .. field.Name .. '" property="' .. field.Name .. '" jdbcType="VARCHAR"/>\n'
            end
        end
        resultMapFieldsCode = resultMapFieldsCode .. '        <result column="created_time" property="createdTime" jdbcType="TIMESTAMP"/>\n'
        resultMapFieldsCode = resultMapFieldsCode .. '        <result column="updated_time" property="updatedTime" jdbcType="TIMESTAMP"/>'
        finalSource = finalSource.gsub(finalSource, '${resultMapFields}', resultMapFieldsCode)

        -- Fill in query params and MyBatis params
        local queryParamsCode = ''
        local insertParamsCode = ''
        local mybatisParamsCode = ''
        local isFirstInsertField = true
        for k = 1, #models[i].Fields do
            local field = models[i].Fields[k]
            if k > 1 then
                queryParamsCode = queryParamsCode .. ', '
            end

            queryParamsCode = queryParamsCode .. '`' .. field.Name .. '`'
            if field.Primary ~= true then
                if isFirstInsertField == true then
                    isFirstInsertField = false
                else
                    insertParamsCode = insertParamsCode .. ', '
                    mybatisParamsCode = mybatisParamsCode .. ', '
                end
                insertParamsCode = insertParamsCode .. '`' .. field.Name .. '`'
                mybatisParamsCode = mybatisParamsCode .. '#{' .. field.Name .. '}'
            end
        end
        queryParamsCode = queryParamsCode .. ', `created_time`, `updated_time`'
        finalSource = finalSource.gsub(finalSource, '${queryParams}', queryParamsCode)
        finalSource = finalSource.gsub(finalSource, '${insertParams}', insertParamsCode)
        finalSource = finalSource.gsub(finalSource, '${mybatisParams}', mybatisParamsCode)

        -- Fill in update fields
        local updateFieldsCode = ''
        local isFirstField = true
        for k = 1, #models[i].Fields do
            local field = models[i].Fields[k]
            if (field.Primary == false) then
                if isFirstField then
                    isFirstField = false
                else
                    updateFieldsCode = updateFieldsCode .. ', '
                end
                updateFieldsCode = updateFieldsCode .. field.Name .. ' = #{' .. field.Name .. '}'
            end
        end
        finalSource = finalSource.gsub(finalSource, '${updateFields}', updateFieldsCode)

        files[ModelName .. 'Mapper.xml'] = finalSource
    end
    return files
end

function generateServices()
    models = project.Models
    files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'Service.java'] = finalSource
    end
    return files
end

function generateServiceImpls()
    models = project.Models
    files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'ServiceImpl.java'] = finalSource
    end
    return files
end

function generateControllers()
    models = project.Models
    files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'Controller.java'] = finalSource
    end
    return files
end

function generateSqlStatements()
    models = project.Models
    local finalSource = ''
    for i = 1, #models do
        local modelName = models[i].Name
        finalSource = finalSource .. 'CREATE TABLE IF NOT EXISTS `' .. models[i].TablePrefix .. modelName .. '` (\n'
        for k = 1, #models[i].Fields do
            local field = models[i].Fields[k]

            -- Fill in field name
            finalSource = finalSource .. '    `' .. field.Name .. '` '

            -- Fill in field type
            local type = field.DbType
            if type == 'VARCHAR' then
                local length = 255
                if field.Length > 0 then length = field.Length end
                type = type .. '(' .. length .. ')'
            end
            finalSource = finalSource .. type

            -- Fill in primary key / null attributes
            if field.Primary then
                finalSource = finalSource .. ' PRIMARY KEY NOT NULL'
                if field.AutoIncrement then
                    finalSource = finalSource .. ' AUTO_INCREMENT'
                end
            elseif field.NotNull then
                finalSource = finalSource .. ' NOT NULL'
            end

            finalSource = finalSource .. ',\n'
        end
        finalSource = finalSource .. '    `created_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n'
        finalSource = finalSource .. '    `updated_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP\n'
        finalSource = finalSource .. ');\n\n'
    end
    files = {}
    files[project.Name .. '.sql'] = finalSource
    return files
end

function generateCrossOriginConfig()
    models = project.Models
    files = {}
    local finalSource = source
    for i = 1, #template.Properties do
        if template.Properties[i].Name == 'cross-origin.allowed-headers' then
            local value = template.Properties[i].Value
            if value == '*' then
                finalSource = string.gsub(finalSource, '${addAllowedHeaders}', 'corsConfiguration.addAllowedHeader("*");')
            else
                -- TODO: split function should be used here
                local headers = string.sub(',', 1)
                local tmp = ''
                for k = 1, #headers do
                    tmp = tmp .. '\n    corsConfiguration.addAllowedHeader("' .. headers[k] .. '");'
                end
                finalSource = string.gsub(finalSource, '${addAllowedHeaders}', tmp)
            end
        end
    end
    -- Remove redundant params
    finalSource = string.gsub(finalSource, '${addAllowedHeaders}', '')
    files['CrossOriginConfig.java'] = finalSource
    return files
end

function generateServiceTests()
    models = project.Models
    files = {}
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        local finalSource = string.gsub(source, '${ModelName}', ModelName)
        finalSource = string.gsub(finalSource, '${modelName}', modelName)
        files[ModelName .. 'ServiceTest.java'] = finalSource
    end
    return files
end

function generatePostmanCollection()
    local finalSource = '{\n' ..
        '    "info": {\n' ..
        '        "_postman_id": "6677f9a2-0725-4a62-8472-221789071ee9",\n' ..
        '        "name": "' .. project.Name .. '",\n' ..
        '        "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"\n' ..
        '    },\n' ..
        '    "item": [\n${items}    ]\n' ..
        '}'
    
    models = project.Models
    local itemSource = ''
    for i = 1, #models do
        local modelName, ModelName = getModelName(models[i])
        itemSource = itemSource .. '        {\n' ..
                                '            "name": "' .. ModelName .. '",\n' ..
                                '            "item": [${subItems}]\n' ..
                                '        }'
        if i == #models then
            itemSource = itemSource .. '\n'
        else
            itemSource = itemSource .. ',\n'
        end
        local subItemSource = ''
        local requestUrl = 'http://localhost:' .. properties['server.port'] .. '/api/' .. properties['project.artifactId'] .. '/' .. modelName
        local paths = '"api", "' .. properties['project.artifactId'] .. '", "' .. modelName .. '"'

        -- GET
        subItemSource = subItemSource .. '\n' .. source .. ','
        subItemSource = string.gsub(subItemSource, '${requestName}', 'Query ' .. ModelName)
        subItemSource = string.gsub(subItemSource, '${requestMethod}', 'GET')
        subItemSource = string.gsub(subItemSource, '${query}', '{ "key": "pageSize", "value": "5" }, { "key": "pageNo", "value": "1" }')
        subItemSource = string.gsub(subItemSource, '${requestBody}', '')
        subItemSource = string.gsub(subItemSource, '${requestUrl}', requestUrl)
        subItemSource = string.gsub(subItemSource, '${paths}', paths)

        -- POST
        subItemSource = subItemSource .. '\n' .. source .. ','
        subItemSource = string.gsub(subItemSource, '${requestName}', 'Create ' .. ModelName)
        subItemSource = string.gsub(subItemSource, '${requestMethod}', 'POST')
        subItemSource = string.gsub(subItemSource, '${query}', '')
        subItemSource = string.gsub(subItemSource, '${requestBody}', '{\\"id\\": 1, \\"name\\": \\"Tom\\"}')
        subItemSource = string.gsub(subItemSource, '${requestUrl}', requestUrl)
        subItemSource = string.gsub(subItemSource, '${paths}', paths)

        -- PUT
        subItemSource = subItemSource .. '\n' .. source .. ','
        subItemSource = string.gsub(subItemSource, '${requestName}', 'Update ' .. ModelName)
        subItemSource = string.gsub(subItemSource, '${requestMethod}', 'PUT')
        subItemSource = string.gsub(subItemSource, '${query}', '')
        subItemSource = string.gsub(subItemSource, '${requestBody}', '')
        subItemSource = string.gsub(subItemSource, '${requestUrl}', requestUrl)
        subItemSource = string.gsub(subItemSource, '${paths}', paths)

        -- DELETE
        subItemSource = subItemSource .. '\n' .. source
        subItemSource = string.gsub(subItemSource, '${requestName}', 'Delete ' .. ModelName)
        subItemSource = string.gsub(subItemSource, '${requestMethod}', 'DELETE')
        subItemSource = string.gsub(subItemSource, '${query}', '')
        subItemSource = string.gsub(subItemSource, '${requestBody}', '')
        subItemSource = string.gsub(subItemSource, '${requestUrl}', requestUrl .. '/1')
        subItemSource = string.gsub(subItemSource, '${paths}', paths .. ', "1"')

        subItemSource = string.gsub(subItemSource, '${requestHost}', 'localhost')
        subItemSource = string.gsub(subItemSource, '${port}', properties['server.port'])
        itemSource = string.gsub(itemSource, '${subItems}', subItemSource)
    end

    finalSource = string.gsub(finalSource, '${items}', itemSource)
    files = {}
    files[project.Name .. '.postman_collection.json'] = finalSource
    return files
end

function generateProperties()
    files = {}

    for i = 1, #(project.Deployment.Env) do
        local env = project.Deployment.Env[i]
        local finalSource = ''

        -- Add MySQL properties
        if #(env.Middleware.Mysql) > 0 then
            local mysql = env.Middleware.Mysql[1]
            local mysqlProperties = go_read_template_file(template.Name, 'content/properties/mysql.properties')
            mysqlProperties = string.gsub(mysqlProperties, '${mysql.Host}', mysql.Host)
            mysqlProperties = string.gsub(mysqlProperties, '${mysql.Port}', tostring(mysql.Port))
            mysqlProperties = string.gsub(mysqlProperties, '${mysql.Database}', mysql.Database)
            mysqlProperties = string.gsub(mysqlProperties, '${mysql.Username}', mysql.Database)
            mysqlProperties = string.gsub(mysqlProperties, '${mysql.Password}', go_jasypt_encrypt(mysql.Password))
            finalSource = finalSource .. mysqlProperties .. '\n\n'
        end

        -- Add Redis properties
        if env.Middleware.Redis ~= nil and #(env.Middleware.Redis) > 0 then
            local redis = env.Middleware.Redis[1]
            local redisProperties = go_read_template_file(template.Name, 'content/properties/redis.properties')
            redisProperties = string.gsub(redisProperties, '${redis.Host}', redis.Host)
            redisProperties = string.gsub(redisProperties, '${redis.Port}', tostring(redis.Port))
            redisProperties = string.gsub(redisProperties, '${redis.Database}', redis.Database)
            redisProperties = string.gsub(redisProperties, '${redis.Password}', go_jasypt_encrypt(redis.Password))
            finalSource = finalSource .. redisProperties .. '\n\n'
        end

        -- Add Passport SDK properties
        if plugins['vancone-passport-sdk'] == true then
            local baseUrl
            if env.Profile == 'pro' or env.Profile == 'prod' then
                baseUrl = 'http://passport.vancone.com'
            else
                baseUrl = 'http://passport.beta.vancone.com'
            end
            local passportSdkProperties = go_read_template_file(template.Name, 'content/properties/vancone-passport-sdk.properties')
            passportSdkProperties = string.gsub(passportSdkProperties, '${passport.baseUrl}', baseUrl)
            passportSdkProperties = string.gsub(passportSdkProperties, '${passport.accessKeyId}', go_jasypt_encrypt(properties['vancone.passport.service-account.access-key-id']))
            passportSdkProperties = string.gsub(passportSdkProperties, '${passport.secretAccessKey}', go_jasypt_encrypt(properties['vancone.passport.service-account.secret-access-key']))
            finalSource = finalSource .. passportSdkProperties .. '\n\n'
        end

        files['application-' .. env.Profile .. '.properties'] = finalSource
    end

    return files
end