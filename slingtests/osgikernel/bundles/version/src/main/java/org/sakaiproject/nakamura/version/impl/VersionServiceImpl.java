/*
 * Licensed to the Sakai Foundation (SF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The SF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

package org.sakaiproject.nakamura.version.impl;

import org.apache.jackrabbit.JcrConstants;
import org.sakaiproject.nakamura.version.VersionService;

import javax.jcr.Node;
import javax.jcr.RepositoryException;
import javax.jcr.UnsupportedRepositoryOperationException;
import javax.jcr.version.Version;

/**
 * Service for doing operations with versions.
 * 
 * @scr.component immediate="true" label="Sakai Versioning Service"
 *                description="Service for doing operations with versions."
 *                name="org.sakaiproject.nakamura.version.VersionService"
 * @scr.property name="service.vendor" value="The Sakai Foundation"
 * @scr.service interface="org.sakaiproject.nakamura.version.VersionService"
 */
public class VersionServiceImpl implements VersionService {

  public Version saveNode(Node node, String savingUsername) throws RepositoryException {
    if (node.canAddMixin("sakai:propertiesmix")) {
      node.addMixin("sakai:propertiesmix");
    }
    node.setProperty(SAVED_BY, savingUsername);
    node.save();
    Version version = null;
    try {
      version = node.checkin();
    } catch ( UnsupportedRepositoryOperationException e) {
      node.addMixin(JcrConstants.MIX_VERSIONABLE);
      node.save();
      version = node.checkin();
    }
    node.checkout();
    if ( node.getSession().hasPendingChanges() ) {
      node.getSession().save();
    }
    return version;
  }

}
